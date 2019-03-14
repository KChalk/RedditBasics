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

from pyspark.ml.feature import CountVectorizer
import codecs

from collections import Counter, defaultdict
from nltk import word_tokenize

   
def main():
    spark = SparkSession \
        .builder \
        .appName("Reddit:Filter posts") \
        .config("spark.some.config.option", "some-value") \
        .getOrCreate()
        
    #file = "RS_full_corpus.bz2"
    file="file:////l2/corpora/reddit/submissions/RS_2016-05.bz2"
    output='filtered_'+file[-14:-4]

    sc = spark.sparkContext
    sub_list= ['leagueoflegends', 'gaming', 'DestinyTheGame', 'DotA2', 'ContestofChampions', 'StarWarsBattlefront', 'Overwatch', 'WWII', 'hearthstone', 'wow', 'heroesofthestorm', 'destiny2', 'darksouls3', 'fallout', 'SuicideWatch', 'depression', 'OCD', 'dpdr', 'proED', 'Anxiety', 'BPD', 'socialanxiety', 'mentalhealth', 'ADHD', 'bipolar', 'buildapc', 'techsupport', 'buildapcforme', 'hacker', 'SuggestALaptop', 'hardwareswap', 'laptops', 'computers', 'pcmasterrace', 'relationshps', 'relationship_advice', 'breakups', 'dating_advice', 'LongDistance', 'polyamory', 'wemetonline', 'MDMA', 'Drugs', 'trees', 'opiates', 'LSD', 'tifu', 'r4r', 'AskReddit', 'reddit.com', 'tipofmytongue', 'Life', 'Advice', 'jobs', 'teenagers', 'HomeImprovement', 'redditinreddit', 'FIFA', 'nba', 'hockey', 'nfl', 'mls', 'baseball', 'BokuNoHeroAcademia', 'anime', 'movies', 'StrangerThings']

    # filter
    print('\n\n\n starting read and filter')
    filtered = filterPosts(file,sc,spark,subs=set(sub_list))

    print('\n\n\n Vectorizing')

    vectors=convertToVec(filtered,sc,spark,output)

    print('\n\n\n Saving')
    ## Save posts
    #filtered.write.parquet(output+'.parquet', mode='overwrite')
    vectors.write.json(output+'.json', mode='overwrite')
    #withvectors.write.json(output+'.json', mode='overwrite')

def tokenize(s):
    tokens=word_tokenize(s.lower())
    counter=Counter(tokens)
    return counter

def sumCounter(C):
    return sum(C.values)

def filterPosts(filename, sc, ss, subs=set(), minwords='100'):
    tokensUDF = udf(tokenize, MapType(StringType(), IntegerType()))
    countUDF = udf(sumCounter, IntegerType())

    alldata = ss.read.json(filename)
    if subs!=set():
        alldata=alldata.filter(alldata.subreddit.isin(subs))

    filtered= alldata \
        .filter(alldata['is_self'] == True) 	\
        .select('id','subreddit',tokensUDF('selftext').alias('counter'))	\
        .withColumn('wordcount', countUDF('counter'))	\
        .filter('wordcount >='+minwords) \
        .select('id','subreddit','counter', 'wordcount')
    return filtered

def convertToVec(df, sc, ss, outputName, inputCol='tokens'):
    cv=CountVectorizer(inputCol=inputCol, outputCol='vectors',minTF=1.0)
    vecModel=cv.fit(df)
    print('\n\n\n Get Vocab... \n\n\n')
    inv_voc=vecModel.vocabulary 
    f = codecs.open(outputName+'_vocab.txt', encoding='utf-8', mode='w')
    for item in inv_voc:
        f.write(u'{0}\n'.format(item))
    f.close()
    vectors= vecModel.transform(df).select('id','subreddit','vectors')
    return vectors

if __name__ == "__main__":
    main()
