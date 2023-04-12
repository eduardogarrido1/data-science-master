package io.keepcoding.spark.exercise.batch

import java.time.OffsetDateTime

import org.apache.spark.sql.functions._
import org.apache.spark.sql.types.DoubleType
import org.apache.spark.sql.{DataFrame, SaveMode, SparkSession}

object DevicesBatchJob extends BatchJob {

  override val spark: SparkSession = SparkSession
    .builder()
    .master("local[*]")
    .appName("Proyecto Eduardo Garrido SQL Batch")
    .getOrCreate()

  import spark.implicits._

  override def readFromStorage(storagePath: String, filterDate: OffsetDateTime): DataFrame = {
    spark
      .read
      .format("parquet")
      .load(s"${storagePath}/data")
      .filter(
        $"year" === filterDate.getYear &&
          $"month" === filterDate.getMonthValue &&
          $"day" === filterDate.getDayOfMonth &&
          $"hour" === filterDate.getHour
      )
  }

  override def readDevicesMetadata(jdbcURI: String, jdbcTable: String, user: String, password: String): DataFrame = {
    spark
      .read
      .format("jdbc")
      .option("url", jdbcURI)
      .option("dbtable", jdbcTable)
      .option("user", user)
      .option("password", password)
      .load()
  }

  override def enrichDevicesWithMetadata(devicesDF: DataFrame, metadataDF: DataFrame): DataFrame = {
    devicesDF.as("devices")
      .join(
        metadataDF.as("metadata"),
        $"devices.id" === $"metadata.id"
      ).drop($"metadata.id")
  }

  override def bytesByAntenna(dataFrame: DataFrame): DataFrame = {
    dataFrame
      .select($"timestamp", $"antenna_id", $"bytes")
      .groupBy($"antenna_id", window($"timestamp", "5 minutes").as("window"))
      .agg(sum($"bytes").as("value"))
      .select($"window.start".as("timestamp"), $"antenna_id".as("id"), $"value", lit("antenna_total_bytes").as("type")) //Informaciones pertinentes bytes
  }

  override def bytesByEmail(dataFrame: DataFrame): DataFrame = {
    dataFrame
      .select($"timestamp", $"email", $"bytes")
      .groupBy($"email", window($"timestamp", "5 minutes").as("window"))
      .agg(sum($"bytes").as("value"))
      .select($"window.start".as("timestamp"), $"email".as("id"), $"value", lit("user_total_bytes").as("type")) //Informaciones pertinentes bytes
  }

  override def bytesByApp(dataFrame: DataFrame): DataFrame = {
    dataFrame
      .select($"timestamp", $"app", $"bytes")
      .groupBy($"app", window($"timestamp", "5 minutes").as("window"))
      .agg(sum($"bytes").as("value"))
      .select($"window.start".as("timestamp"), $"app".as("id"), $"value", lit("app_total_bytes").as("type")) //Informaciones pertinentes bytes
  }

  override def bytesByQuota(dataFrame: DataFrame): DataFrame = {
    dataFrame
      .select($"timestamp", $"email", $"quota", $"bytes")
      .groupBy($"email", window($"timestamp", "5 minutes"))
      .agg(
        sum($"bytes").as("usage"),
        max($"usage").as("quota")
      )
      .where($"usage" > $"quota")
      .select($"window.start".as("timestamp"), $"email", $"usage", $"quota")
  }

  override def writeToJdbc(dataFrame: DataFrame, jdbcURI: String, jdbcTable: String, user: String, password: String): Unit = {
    dataFrame
      .write
      .mode(SaveMode.Append)
      .format("jdbc")
      .option("driver", "org.postgresql.Driver")
      .option("url", jdbcURI)
      .option("dbtable", jdbcTable)
      .option("user", user)
      .option("password", password)
      .save()
  }

  override def writeToStorage(dataFrame: DataFrame, storageRootPath: String): Unit = {
    dataFrame
      .write
      .option("path", s"$storageRootPath/data")
      .option("checkpointLocation", s"$storageRootPath/checkpoint")
      .partitionBy("year", "month", "day", "hour")
      .format("parquet")
      .mode(SaveMode.Overwrite)
      .save(s"${storageRootPath}/historical")
  }

  def main(args: Array[String]): Unit = {
    val jdbcUri = "jdbc:postgresql://34.173.65.17:5432/postgres"
    val jdbcUser = "postgres"
    val jdbcPassword = "keepcoding"

    val offsetDateTime = OffsetDateTime.parse("2022-10-31T17:00:00Z")
    val parquetDF = readFromStorage("/tmp/devices_parquet/", offsetDateTime)
    val metadataDF = readDevicesMetadata(jdbcUri, "user_metadata", jdbcUser, jdbcPassword)
    val DevicesMetadataDF = enrichDevicesWithMetadata(parquetDF, metadataDF).cache()

    val agg_by_antenna_DF = bytesByAntenna(DevicesMetadataDF)
    val agg_by_email_DF = bytesByEmail(DevicesMetadataDF)
    val agg_by_app_DF = bytesByApp(DevicesMetadataDF)
    val agg_by_quota_DF = bytesByQuota(DevicesMetadataDF)

    writeToJdbc(agg_by_antenna_DF, jdbcUri, "bytes_hourly", jdbcUser, jdbcPassword)
    writeToJdbc(agg_by_email_DF, jdbcUri, "bytes_hourly", jdbcUser, jdbcPassword)
    writeToJdbc(agg_by_app_DF, jdbcUri, "bytes_hourly", jdbcUser, jdbcPassword)
    writeToJdbc(agg_by_quota_DF, jdbcUri, "user_quota_limit", jdbcUser, jdbcPassword)
    writeToStorage(parquetDF, "/tmp/devices_parquet/")

    spark.close()
  }

}
