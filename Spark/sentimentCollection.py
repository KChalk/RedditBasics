from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark.sql.functions import size, split
from operator import add
import json
from pyspark.sql.functions import udf
from pyspark.sql.types import IntegerType, ArrayType, MapType, StringType
from collections import defaultdict, Counter
import csv
import re 
from string import punctuation
import numpy as np
from pyspark.ml.feature import CountVectorizer
import codecs
from pyspark.sql.functions import lit

class SentimentCollection:
    def __init__ (self):
        self.name_list=[] 
        self.num_to_name={}
        self.name_to_words={}
        self.vocab_to_names=defaultdict(list)

    def add_sentiment(self, num, name, words):
        self.name_list.append(name)
        self.num_to_name[num]=name
        self.name_to_words[name]=words
        for w in words: 
            self.vocab_to_names[w].append(name)

    def populate_from_file(self,filename):
        state=0
        with open(filename) as file:
            for line in file:  
                line=line.strip()

                if state == 0: 
                    assert (line == '%'), "Syntax error in input file"

                if line=='%':
                    state+=1 
                    continue

                elif state==1: 
                    #in list of dicionary names and codes #change to elif
                    col_num, col_name=line.split('\t')
                    self.add_sentiment(col_num, col_name,[]) 

                elif state==2: 
                    #in list of words followed by list of dicts they belong to 
                    line=line.split('\t')
                    word=line[0]
                    
                    for sentiment_num in line[1:]:
                        sentiment_name = self.num_to_name[sentiment_num]
                        self.name_to_words[sentiment_name].append(word)
                        self.vocab_to_names[word].append(sentiment_name)
                        
        assert (state < 3), "Syntax error in input file"
        return self

    def match_prefix_to_sentiments(self, word):
        if word in self.vocab_to_names:
            return self.vocab_to_names[word]

        prefix=word[:-1]
        while prefix != '':
            if prefix+'*' in self.vocab_to_names:
                return self.vocab_to_names[prefix+'*']

            prefix = prefix[:-1]
        return []
