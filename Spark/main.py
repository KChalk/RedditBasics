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

from filterposts import filterPosts, convertToVec
from wordCollection import WordCollection, add_wc_freq

def main():
    spark = SparkSession \
        .builder \
        .appName("Reddit:Revised") \
        .getOrCreate()
        
    #file = "RS_full_corpus.bz2"
    file="file:////l2/corpora/reddit/submissions/RS_2016-05.bz2"
    output='coll_freqs_'+file[-14:-4]

    sc = spark.sparkContext
    sub_list= ['leagueoflegends', 'gaming', 'DestinyTheGame', 'DotA2', 'ContestofChampions', 'StarWarsBattlefront', 'Overwatch', 'WWII', 'hearthstone', 'wow', 'heroesofthestorm', 'destiny2', 'darksouls3', 'fallout', 'SuicideWatch', 'depression', 'OCD', 'dpdr', 'proED', 'Anxiety', 'BPD', 'socialanxiety', 'mentalhealth', 'ADHD', 'bipolar', 'buildapc', 'techsupport', 'buildapcforme', 'hacker', 'SuggestALaptop', 'hardwareswap', 'laptops', 'computers', 'pcmasterrace', 'relationshps', 'relationship_advice', 'breakups', 'dating_advice', 'LongDistance', 'polyamory', 'wemetonline', 'MDMA', 'Drugs', 'trees', 'opiates', 'LSD', 'tifu', 'r4r', 'AskReddit', 'reddit.com', 'tipofmytongue', 'Life', 'Advice', 'jobs', 'teenagers', 'HomeImprovement', 'redditinreddit', 'FIFA', 'nba', 'hockey', 'nfl', 'mls', 'baseball', 'BokuNoHeroAcademia', 'anime', 'movies', 'StrangerThings']

    # filter
    print('\n\n\n starting read and filter')
    filtered = filterPosts(file,sc,spark,subs=set(sub_list))

    file="/mnt/filevault-b/2/homes/chalkley/cluster/RedditProject/sequential/wordCollections.dic"

    WordCollection.wcs_from_file(file)
    absolutist = ['absolutely', 'all', 'always', 'complete', 'competely','constant', 'constantly', 'definitely', 'entire', 'ever', 'every', 'everyone', 'everything', 'full', 'must', 'never', 'nothing', 'totally','whole']
    WordCollection(0,'absolutist', absolutist)
    
    print('\n\n\n Getting Collection Frequencies')

    collection_freqs=add_wc_freq(filtered,sc,spark)

    collection_freqs.write.csv(output+'.csv', mode='overwrite')

    #print('\n\n\n Vectorizing')

    #vectors=convertToVec(filtered,sc,spark,output)

















if __name__ == "__main__":
    main()

