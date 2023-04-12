package io.keepcoding.spark.exercise.streaming

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.{Await, Future}
import org.apache.spark.sql.{DataFrame, SaveMode, SparkSession}
import org.apache.spark.sql.catalyst.ScalaReflection
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types.{StringType, StructType, StructField, TimestampType}

import scala.concurrent.duration.Duration

object DevicesStreamingJob extends StreamingJob {

  override val spark: SparkSession = SparkSession
    .builder()
    .master("local[20]")
    .appName("Proyecto Eduardo Garrido SQL Streaming")
    .getOrCreate()

  import spark.implicits._

  override def readFromKafka(kafkaServer: String, topic: String): DataFrame = {
    spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", kafkaServer)
      .option("subscribe", topic)
      .load()
  }

  override def parserJsonData(dataFrame: DataFrame): DataFrame = {
    val jsonSchema = StructType(Seq(
      StructField("timestamp", TimestampType, nullable = false),
      StructField("id", StringType, nullable = false),
      StructField("antenna_id", StringType, nullable = false),
      StructField("bytes", IntegerType, nullable = false)
      StructField("app", StringType, nullable = false)
    )
    )

    dataFrame
      .select(from_json(col("value").cast(StringType), jsonSchema).as("json"))
      .select("json.*")
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

  override def enrichDevicesWithMetadata(DevicesDF: DataFrame, metadataDF: DataFrame): DataFrame = {
    DevicesDF.as("devices")
      .join(
        metadataDF.as("metadata"),
        $"devices.id" === $"metadata.id"
      ).drop($"metadata.id")
  }

  override def bytesByAntenna(dataFrame: DataFrame): DataFrame = {
    dataFrame
      .select($"timestamp", $"antenna_id", $"bytes")
      .withWatermark("timestamp", "1 minute")
      .groupBy($"antenna_id", window($"timestamp", "5 minutes").as("window"))
      .agg(sum($"bytes").as("value"))
      .select($"window.start".as("timestamp"), $"antenna_id".as("id"), $"value", lit("antenna_total_bytes").as("type")) //Informaciones pertinentes bytes
  }

  override def bytesByUser(dataFrame: DataFrame): DataFrame = {
    dataFrame
      .select($"timestamp", $"id", $"bytes")
      .withWatermark("timestamp", "1 minute")
      .groupBy($"id", window($"timestamp", "5 minutes").as("window"))
      .agg(sum($"bytes").as("value"))
      .select($"window.start".as("timestamp"), $"id", $"value", lit("user_total_bytes").as("type")) //Informaciones pertinentes bytes
  }

  override def bytesByApp(dataFrame: DataFrame): DataFrame = {
    dataFrame
      .select($"timestamp", $"app", $"bytes")
      .withWatermark("timestamp", "1 minute")
      .groupBy($"app", window($"timestamp", "5 minutes").as("window"))
      .agg(sum($"bytes").as("value"))
      .select($"window.start".as("timestamp"), $"app".as("id"), $"value", lit("app_total_bytes").as("type")) //Informaciones pertinentes bytes
  }

  override def writeToJdbc(dataFrame: DataFrame, jdbcURI: String, jdbcTable: String, user: String, password: String): Future[Unit] = Future {
    dataFrame
      .writeStream
      .foreachBatch { (data: DataFrame, batchId: Long) =>
        data
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
      .start()
      .awaitTermination()
  }

  override def writeToStorage(dataFrame: DataFrame, storageRootPath: String): Future[Unit] = Future {
    dataFrame
      .select(
        $"timestamp", $"id", $"antenna_id", $"bytes", $"app",
        year($"timestamp").as("year"),
        month($"timestamp").as("month"),
        dayofmonth($"timestamp").as("day"),
        hour($"timestamp").as("hour"),
      )
      .writeStream
      .format("parquet")
      .option("path", s"$storageRootPath/data")
      .option("checkpointLocation", s"$storageRootPath/checkpoint")
      .partitionBy("year", "month", "day", "hour")
      .start
      .awaitTermination()
  }

  def main(args: Array[String]): Unit = {
    //run(args)
    val kafkaDF = readFromKafka("34.125.217.189:9092", "devices")
    val parsedDF = parserJsonData(kafkaDF)
    val storageFuture = writeToStorage(parsedDF, "/tmp/devices_parquet/")
    val metadataDF = readDevicesMetadata(
      "jdbc:postgresql://34.173.65.17:5432/postgres",
      "user_metadata",
      "postgres",
      "keepcoding"
    )
    val enrichDF = enrichDevicesWithMetadata(parsedDF, metadaDF)
    val bytes_by_antenna = bytesByAntenna(enrichDF)
    val bytes_by_user = bytesByUser(enrichDF)
    val bytes_by_app = bytesByApp(enrichDF)
    val jdbcFutureByAntenna = writeToJdbc(bytes_by_antenna, "jdbc:postgresql://34.173.65.17:5432/postgres", "bytes", "postgres", "keepcoding")
    val jdbcFutureByUser = writeToJdbc(bytes_by_user, "jdbc:postgresql://34.173.65.17:5432/postgres", "bytes", "postgres", "keepcoding")
    val jdbcFutureByApp = writeToJdbc(bytes_by_app, "jdbc:postgresql://34.173.65.17:5432/postgres", "bytes", "postgres", "keepcoding")

    Await.result(
      Future.sequence(Seq(storageFuture, jdbcFutureByAntenna, jdbcFutureByUser, jdbcFutureByApp)), Duration.Inf
    )

    spark.close()
  }
}
