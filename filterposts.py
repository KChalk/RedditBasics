# large parquet
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark.sql.functions import size, split
from operator import add
import json
from pyspark.sql.functions import udf
from pyspark.sql.types import IntegerType, ArrayType, MapType, StringType
from collections import defaultdict
import csv
import re 
from string import punctuation

   
def main():
    spark = SparkSession \
        .builder \
        .appName("Reddit:Filter posts") \
        .config("spark.some.config.option", "some-value") \
        .getOrCreate()
        
    #file = "RS_full_corpus.bz2"
    file="file:////l2/corpora/reddit/submissions/RS_2013-01.bz2"
    output='filtered'+file[-14:-4]

    sc = spark.sparkContext

    # filter
    print('\n\n\n starting read and filter')
    filtered = filterPosts(file)

    print('\n\n\n Saving')
    ## Save posts
    filtered.write.parquet(output+'.parquet', mode='overwrite')
    #filtered.write.json(output+'.json', mode='overwrite')
    #withvectors.write.json(output+'.json', mode='overwrite')

def tokenize(s):
    tokens=[]
    s=s.strip().lower()
    wordlist=re.split("[\s;,#]", s)
    for word in wordlist: 
        word=re.sub('^[\W\d]*','',word)
        word=re.sub('[\W\d]*$','',word)
        if word != '':
            tokens.append(word)
    return tokens

def filterPosts(filename, sc=sc, ss=spark, subs=set(), minwords='100', columns=['id','subreddit']):
    tokensUDF = udf(tokenize, ArrayType(StringType())) 
    alldata = ss.read.json(filename)
    columns=columns.append(tokensUDF('selftext').alias("tokens"))
    if subs!=set():
        alldata=alldata.filter(alldata['subreddit'] in subs)

    filtered= alldata \
        .filter(alldata['is_self'] == True) 	\
        .select(*columns)	\
        .withColumn('wordcount', size('tokens'))	\
        .filter('wordcount >='+minwords)
    return filtered

if __name__ == "__main__":
    main()
