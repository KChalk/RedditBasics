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
    spark = SparkSession \
        .builder \
        .appName("Reddit:Revised") \
        .getOrCreate()

    sc = spark.sparkContext

    reloadFiles=False
    collectFiles=True
    badMonths=[(12,17),(6,12),(11,1)]
    #add list of poorly nehaving files, to include 2012-06
    if reloadFiles:
        files=[]
        file_prefix='file:////l2/corpora/reddit/submissions/RS_20'
        file_suffix='.bz2'
        for y in range(12,18):
            for m in range(1,13):
                if (m,y) in badMonths:
                    continue
                    
                filename=file_prefix + str(y) + "-{0:0=2d}".format(m) +file_suffix
                files.append(filename)

        sub_list= ['leagueoflegends', 'gaming', 'DestinyTheGame', 'DotA2', 'ContestofChampions', 'StarWarsBattlefront', 'Overwatch', 'WWII', 'hearthstone', 'wow', 'heroesofthestorm', 'destiny2', 'darksouls3', 'fallout', 'SuicideWatch', 'depression', 'OCD', 'dpdr', 'proED', 'Anxiety', 'BPD', 'socialanxiety', 'mentalhealth', 'ADHD', 'bipolar', 'buildapc', 'techsupport', 'buildapcforme', 'hacker', 'SuggestALaptop', 'hardwareswap', 'laptops', 'computers', 'pcmasterrace', 'relationshps', 'relationship_advice', 'breakups', 'dating_advice', 'LongDistance', 'polyamory', 'wemetonline', 'MDMA', 'Drugs', 'trees', 'opiates', 'LSD', 'tifu', 'r4r', 'AskReddit', 'reddit.com', 'tipofmytongue', 'Life', 'Advice', 'jobs', 'teenagers', 'HomeImprovement', 'redditinreddit', 'FIFA', 'nba', 'hockey', 'nfl', 'mls', 'baseball', 'BokuNoHeroAcademia', 'anime', 'movies', 'StrangerThings']
        # filter
        print('\n\n\n starting read and filter')
        filtered = filterPosts(files,sc,spark,subs=set(sub_list))
        filtered.write.parquet('filtered_all.parquet', mode='overwrite')

    elif collectFiles: 
        file_prefix='filtered_'
        file_suffix='.parquet'
        firstFile=True

        for y in range(12,18):
            for m in range(1,13):
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
    
    part2=False
    if part2:
        file="/mnt/filevault-b/2/homes/chalkley/cluster/RedditProject/Spark/wordCollections.dic"
        output='collection_frequencies'

        WordCollection.wcs_from_file(file)
        
        print('\n\n\n Getting Collection Frequencies')

        collection_freqs=add_wc_freq(filtered,sc,spark)

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


class WordCollection: 
    obj_list=[] 
    num_to_obj={}
    name_to_obj={}
    vocab_to_objs=defaultdict(list)

    def __init__(self, num, name, words): 
        self.num=num
        self.name=name
        self.nomen=name
        self.words=words 
        WordCollection.obj_list.append(self)
        WordCollection.num_to_obj[num]=self
        WordCollection.name_to_obj[name]=self
        for w in words: 
            WordCollection.vocab_to_objs[w].append(self)# possibly use new add word method here
    
    def add_word(self,word):
        WordCollection.vocab_to_objs[word].append(self)
        self.words.append(word) # Probably not actually necessary, should probably get rid of this

    @classmethod    
    def wcs_from_file(cls, filename): # add abs
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
                    WordCollection(col_num,col_name,[]) 

                elif state==2: 
                    #in list of words followed by list of dicts they belong to 
                    line=line.split('\t')
                    word=line[0]
                    
                    if word[-1]=='*': #remove *'s-- program will not distinguish between words and prefixes
                        word=word[:-1]
                    
                    for col_num in line[1:]:
                        obj= cls.num_to_obj[col_num]
                        obj.add_word(word)
                        
        assert (state < 3), "Syntax error in input file"
        return WordCollection

    @classmethod    
    def match_prefix_to_wcs(cls, word):
        print('word',word)
        if word in cls.vocab_to_objs:
            print('total match',cls.vocab_to_objs[word])
            return cls.vocab_to_objs[word]

        prefix=word[:-1]
        while prefix != '':
            if prefix+'*' in cls.vocab_to_objs:
                print('partial match',cls.vocab_to_objs[prefix+'*'])
                return cls.vocab_to_objs[prefix+'*']

            prefix = prefix[:-1]

        print('no match',word) #mysteriously never matches anything. 
        return []
   
def getCounts(words_counter): 
    wc_counts=Counter()
    for word, count in words_counter.items(): 
        wcs=WordCollection.match_prefix_to_wcs(word)
        
        for wc in wcs:
            wc_counts[wc.nomen]+=count
    return dict(wc_counts)
    

def add_wc_freq(df,sc,ss,inputCol='counter'):
    getCountsUDF=udf(getCounts, MapType(StringType(),IntegerType()))

    df= df.select('id','subreddit', 'month', 'wordcount', getCountsUDF(inputCol).alias('collection_counts'))

    for d in WordCollection.obj_list: 
        df=df.withColumn(d.nomen, df['collection_counts'][d.nomen])

    df=df.drop('collection_counts')
    #aggregate per dict counts by subreddit
    agg = df.groupby(df['subreddit'], df['month']) \
        .agg({"*": "count", "wordcount": "sum", 'absolutist': "sum",'funct' : "sum", 'pronoun' : "sum", 'i' : "sum", 'we' : "sum", 'you' : "sum", 'shehe' : "sum", 'they' : "sum", 'article' : "sum", 'verb' : "sum", 'auxverb' : "sum", 'past' : "sum", 'present' : "sum", 'future' : "sum", 'adverb' : "sum", 'preps' : "sum", 'conjunctions': 'sum','negate' : "sum", 'quant' : "sum", 'number' : "sum", 'swear' : "sum", 'social' : "sum", 'family' : "sum", 'friend' : "sum", 'humans' : "sum", 'affect' : "sum", 'posemo' : "sum", 'negemo' : "sum", 'anx' : "sum", 'anger' : "sum", 'sad' : "sum", 'cogmech' : "sum", 'insight' : "sum", 'cause' : "sum", 'discrep' : "sum", 'tentat' : "sum", 'certain' : "sum", 'inhib' : "sum", 'percept' : "sum", 'bio' : "sum", 'body' : "sum", 'ingest' : "sum", 'relativ' : "sum", 'motion' : "sum", 'space' : "sum", 'time' : "sum", 'work' : "sum", 'achieve' : "sum", 'leisure' : "sum", 'home' : "sum", 'money' : "sum", 'relig' : "sum", 'death' : "sum", 'assent' : "sum", 'nonfl' : "sum", 'filler' : "sum"})
    agg =agg.filter(agg['count(1)']>=100)

    print('\n\n\n finished group with filter \n\n\n' )

    for d in WordCollection.obj_list: 
        agg=agg.withColumn(d.nomen+'_freq', agg['sum('+d.nomen+')']/agg['sum(wordcount)']) \
            .drop(agg['sum('+d.nomen+')'])

    return agg















if __name__ == "__main__":
    main()

