
from __future__ import absolute_import

import argparse
import logging
import re
import os
import csv
import json
import random

from past.builtins import unicode

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToText
from apache_beam.coders.coders import Coder
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions, DirectOptions

import nltk
from nltk.corpus import stopwords
from nltk.stem import SnowballStemmer

nltk.download("stopwords")

# CLEANING
STOP_WORDS = stopwords.words("english")
STEMMER = SnowballStemmer("english")
TEXT_CLEANING_RE = "@\S+|https?:\S+|http?:\S|[^A-Za-z0-9]+"


class CustomCoder(Coder): 
    """Custom coder utilizado para leer y escribir strings."""

    def __init__(self, encoding: str):
        # latin-1
        # iso-8859-1
        self.enconding = encoding

    def encode(self, value):
        return value.encode(self.enconding)

    def decode(self, value):
        return value.decode(self.enconding)

    def is_deterministic(self):
        return True


class ExtractColumnsDoFn(beam.DoFn):
    def process(self, element):
        data = json.loads(element)
        data = [data['content'], data['annotation']['label'][0]]
        yield data


class PreprocessColumnsTrainFn(beam.DoFn):

    def process_sentiment(self, value):
        sentiment = int(value)
        if sentiment == 1:
            return "TROLL"
        else:
            return "NOTROLL"

    def process_text(self, text):
        
        stem = False
        text = re.sub(TEXT_CLEANING_RE, " ", str(text).lower()).strip()
        tokens = []
        for token in text.split():
            if token not in STOP_WORDS:
                if stem:
                    tokens.append(STEMMER.stem(token))
                else:
                    tokens.append(token)
        return " ".join(tokens)

    def process(self, element):
        processed_text = self.process_text(element[0])
        processed_sentiment = self.process_sentiment(element[1]) 
        yield f"{processed_text}, {processed_sentiment}"







def run(argv=None, save_main_session=True):

  """Main entry point; defines and runs the wordcount pipeline."""



  parser = argparse.ArgumentParser()

  parser.add_argument(
        "--work-dir",
        dest="work_dir",
        required=True,
        help="Working directory",
  )

  parser.add_argument(
        "--input",
        dest="input",
        required=True,
        help="Input dataset in work dir",
    )
  parser.add_argument(
        "--output",
        dest="output",
        required=True,
        help="Output path to store transformed data in work dir",
    )
  parser.add_argument(
        "--mode",
        dest="mode",
        required=True,
        choices=["train", "test"],
        help="Type of output to store transformed data",
    )



  known_args, pipeline_args = parser.parse_known_args(argv)

  
  
  
  # Pipeline Options
  pipeline_options = PipelineOptions(pipeline_args)
  pipeline_options.view_as(SetupOptions).save_main_session = save_main_session 
  pipeline_options.view_as(DirectOptions).direct_num_workers = 0

  
  
  
  
  # Writing the Pipeline
  with beam.Pipeline(options=pipeline_options) as p:
    
    
    
    raw_data = p | "ReadTwitterData" >> ReadFromText(
            known_args.input,
            coder=CustomCoder("latin-1"))
    
    
    
    
    if known_args.mode == "train":

      transformed_data = (
                raw_data
                | "ExtractColumns" >> beam.ParDo(ExtractColumnsDoFn())
                | "Preprocess" >> beam.ParDo(PreprocessColumnsTrainFn()) 
            )
      
      eval_percent = 20
      assert 0 < eval_percent < 100, "eval_percent must in the range (0-100)"
      train_dataset, eval_dataset = (
                transformed_data
                | "Split dataset"
                >> beam.Partition(
                    lambda elem, _: int(random.uniform(0, 100) < eval_percent), 2 
                ) 
            )

      train_dataset | "TrainWriteToCSV" >> WriteToText(
                os.path.join(known_args.output, "train", "part"), 
    file_name_suffix=".csv"
            )
      eval_dataset | "EvalWriteToCSV" >> WriteToText(
                os.path.join(known_args.output, "eval", "part"), 
    file_name_suffix=".csv"
            )

    else:
      transformed_data = (
                raw_data
                | "ExtractColumns" >> beam.ParDo(ExtractColumnsDoFn())
                | "Preprocess" >> beam.Map(lambda x: f'"{x[0]}"')
            )

      transformed_data | "TestWriteToCSV" >> WriteToText(
                os.path.join(known_args.output, "test", "part"), 
    file_name_suffix=".csv"
            )


if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    run()
