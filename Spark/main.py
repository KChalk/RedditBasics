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
#from nltk import word_tokenize
# Get a local spark version. Get it. 

def main():
    print('foo')

    spark = SparkSession \
        .builder \
        .appName("Reddit:Revised") \
        .getOrCreate()

    sc = spark.sparkContext
    sc.addFile("sentimentCollection.py")
    from sentimentCollection import SentimentCollection

    reloadFiles=False
    collectFiles=False
    badMonths=[(12,17),(6,12),(11,1)]
    #add list of poorly nehaving files, to include 2012-06

    if reloadFiles: # know whether this is head node or all executors -> make into broadcast variable.
        files=[]
        file_prefix='file:////l2/corpora/reddit/submissions/RS_20'
        file_suffix='.bz2'
        for y in range(12,13):
            for m in range(1,3):
                if (m,y) in badMonths:
                    continue
                    
                filename=file_prefix + str(y) + "-{0:0=2d}".format(m) +file_suffix
                files.append(filename)

        sub_list= ['leagueoflegends', 'gaming', 'DestinyTheGame', 'DotA2', 'ContestofChampions', 'StarWarsBattlefront', 'Overwatch', 'WWII', 'hearthstone', 'wow', 'heroesofthestorm', 'destiny2', 'darksouls3', 'fallout', 'SuicideWatch', 'depression', 'OCD', 'dpdr', 'proED', 'Anxiety', 'BPD', 'socialanxiety', 'mentalhealth', 'ADHD', 'bipolar', 'buildapc', 'techsupport', 'buildapcforme', 'hacker', 'SuggestALaptop', 'hardwareswap', 'laptops', 'computers', 'pcmasterrace', 'relationshps', 'relationship_advice', 'breakups', 'dating_advice', 'LongDistance', 'polyamory', 'wemetonline', 'MDMA', 'Drugs', 'trees', 'opiates', 'LSD', 'tifu', 'r4r', 'AskReddit', 'reddit.com', 'tipofmytongue', 'Life', 'Advice', 'jobs', 'teenagers', 'HomeImprovement', 'redditinreddit', 'FIFA', 'nba', 'hockey', 'nfl', 'mls', 'baseball', 'BokuNoHeroAcademia', 'anime', 'movies', 'StrangerThings']
        # filter
        print('\n\n\n starting read and filter')
        filtered = filterPosts(files,sc,spark,subs=set(sub_list)) # also saves filtered posts by month
        filtered.write.parquet('filtered_all.parquet', mode='overwrite')

    elif collectFiles: 
        file_prefix='filtered_'
        file_suffix='.parquet'
        firstFile=True

        for y in range(12,18):
            for m in range(1,3):
                if (m,y) in badMonths:
                    continue
                filename=file_prefix + str(y) + "-{0:0=2d}".format(m) +file_suffix
                filtered_month=spark.read.parquet(filename)

                if firstFile:
                    filtered=filtered_month
                    firstFile=False
                else:
                    filtered=filtered.union(filtered_month)
        filtered.write.parquet('filtered_all.parquet', mode='overwrite')

    else:
        filtered=spark.read.parquet('filtered_all.parquet')
    
    part2=True
    if part2:
        file="/mnt/filevault-b/2/homes/chalkley/cluster/RedditProject/Spark/wordCollections.dic"
        output='collection_frequencies'

        sentiments = SentimentCollection()
        sentiments.populate_from_file(file)
        
        global SENTIMENTS
        SENTIMENTS = sc.broadcast(sentiments)        

        print('\n\n\n Getting Collection Frequencies')

        collection_freqs=add_wc_freq(filtered, sc,spark)
    
        print('\n\n\n writing')

        collection_freqs.write.csv(output+'.csv', mode='overwrite', header=True)

    #print('\n\n\n Vectorizing')

    #vectors=convertToVec(filtered,sc,spark,output)

def tokenize(s):
    tokens=[]
    s=s.strip().lower()
    wordlist=re.split("[\s;,#]", s)
    for word in wordlist: 
        word=re.sub('^[\W\d]*','',word)
        word=re.sub('[\W\d]*$','',word)
        if word != '':
            tokens.append(word)

    counter=Counter(tokens)
    return dict(counter)
'''
def tokenize_nltk(s):
    tokens=word_tokenize(s.lower())
    counter=Counter(tokens)
    return counter
'''
def sumCounter(C):
    return sum(C.values())

#file map branch idea. sc.parallel(filelist).foreach(filterposts)
def filterPosts(fileList, sc, ss, subs=set(), minwords='100'):
    tokensUDF = udf(tokenize, MapType(StringType(),IntegerType()))
    countUDF = udf(sumCounter, IntegerType())

    firstFile=True
    for filename in fileList:
        month=filename[-9:-4]
        print('\n\n\n reading', month, filename)
        monthData = ss.read.json(filename)

        if subs!=set():
            monthData=monthData.filter(monthData.subreddit.isin(subs))

        filtered= monthData \
            .filter(monthData['is_self'] == True) 	\
            .select('id','subreddit', tokensUDF('selftext').alias('counter'))	\
            .withColumn('wordcount', countUDF('counter'))	\
            .filter('wordcount >='+minwords) \
            .select('id','subreddit','counter', 'wordcount') \
            .withColumn('month', lit(month))
        print('\n\n\n saving', month)
        filtered.write.parquet('filtered_'+month+'.parquet', mode='overwrite')
        if firstFile:
            alldata=filtered
            firstFile=False
        else:
            alldata=alldata.union(filtered)

    return alldata

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

   
def getCounts(words_counter): 
    print('counting')
    wc_counts=Counter()
    for word, count in words_counter.items(): 
        wcs=SENTIMENTS.value.match_prefix_to_sentiments(word)
        
        for wc in wcs:
            wc_counts[wc]+=count
    return dict(wc_counts)
    

def add_wc_freq(df, sc,ss,inputCol='counter'):
    getCountsUDF=udf(getCounts, MapType(StringType(),IntegerType()))

    df= df.select('id','subreddit', 'month', 'wordcount', getCountsUDF(inputCol).alias('collection_counts'))
    print('selected columns')

    for d in SENTIMENTS.value.name_list: 
        df=df.withColumn(d, df['collection_counts'][d])

    df=df.drop('collection_counts')
    #aggregate per dict counts by subreddit
    print('grouping')

    agg = df.groupby(df['subreddit'], df['month']) \
        .agg({"*": "count", "wordcount": "sum", 'absolutist': "sum",'funct' : "sum", 'pronoun' : "sum", 'i' : "sum", 'we' : "sum", 'you' : "sum", 'shehe' : "sum", 'they' : "sum", 'article' : "sum", 'verb' : "sum", 'auxverb' : "sum", 'past' : "sum", 'present' : "sum", 'future' : "sum", 'adverb' : "sum", 'preps' : "sum", 'conjunctions': 'sum','negate' : "sum", 'quant' : "sum", 'number' : "sum", 'swear' : "sum", 'social' : "sum", 'family' : "sum", 'friend' : "sum", 'humans' : "sum", 'affect' : "sum", 'posemo' : "sum", 'negemo' : "sum", 'anx' : "sum", 'anger' : "sum", 'sad' : "sum", 'cogmech' : "sum", 'insight' : "sum", 'cause' : "sum", 'discrep' : "sum", 'tentat' : "sum", 'certain' : "sum", 'inhib' : "sum", 'percept' : "sum", 'bio' : "sum", 'body' : "sum", 'ingest' : "sum", 'relativ' : "sum", 'motion' : "sum", 'space' : "sum", 'time' : "sum", 'work' : "sum", 'achieve' : "sum", 'leisure' : "sum", 'home' : "sum", 'money' : "sum", 'relig' : "sum", 'death' : "sum", 'assent' : "sum", 'nonfl' : "sum", 'filler' : "sum"})
    agg = agg.filter(agg['count(1)']>=100)

    print('\n\n\n finished group with filter \n\n\n' )

    for d in SENTIMENTS.value.name_list: 
        agg=agg.withColumn(d+'_freq', agg['sum('+d+')']/agg['sum(wordcount)']) \
            .drop(agg['sum('+d+')'])

    return agg


if __name__ == "__main__":
    main()

