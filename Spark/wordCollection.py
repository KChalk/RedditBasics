from collections import Counter, defaultdict
import re 
#from string import punctuation
from nltk import word_tokenize
from pyspark.sql.functions import udf, size,split
from pyspark.sql.types import IntegerType, MapType, StringType


# add * based prefix matching. 

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
    def wcs_from_file(cls, filename):
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
                    col_name, col_num=line.split('\t')
                    WordCollection(col_name,col_num,[]) 

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
    return wc_counts
    

def add_wc_freq(df,sc,ss,inputCol='counter'):
    getCountsUDF=udf(getCounts,  MapType(StringType(), IntegerType()))

    df= df.select('id','subreddit','wordcount', getCountsUDF(inputCol).alias('collection_counts'))

    for d in WordCollection.obj_list: 
        df=df.withColumn(d.nomen, df['collection_counts'][d.nomen])

    df=df.drop('collection_counts')
    #aggregate per dict counts by subreddit
    agg = df.groupby(df['subreddit']) \
        .agg({"*": "count", "wordcount": "sum", 'absolutist': "sum",'funct' : "sum", 'pronoun' : "sum", 'i' : "sum", 'we' : "sum", 'you' : "sum", 'shehe' : "sum", 'they' : "sum", 'article' : "sum", 'verb' : "sum", 'auxverb' : "sum", 'past' : "sum", 'present' : "sum", 'future' : "sum", 'adverb' : "sum", 'preps' : "sum", 'conjunctions':
'sum','negate' : "sum", 'quant' : "sum", 'number' : "sum", 'swear' : "sum", 'social' : "sum", 'family' : "sum", 'friend' : "sum", 'humans' : "sum", 'affect' : "sum", 'posemo' : "sum", 'negemo' : "sum", 'anx' : "sum", 'anger' : "sum", 'sad' : "sum", 'cogmech' : "sum", 'insight' : "sum", 'cause' : "sum", 'discrep' : "sum", 'tentat' : "sum", 'certain' : "sum", 'inhib' : "sum", 'percept' : "sum", 'bio' : "sum", 'body' : "sum", 'ingest' : "sum", 'relativ' : "sum", 'motion' : "sum", 'space' : "sum", 'time' : "sum", 'work' : "sum", 'achieve' : "sum", 'leisure' : "sum", 'home' : "sum", 'money' : "sum", 'relig' : "sum", 'death' : "sum", 'assent' : "sum", 'nonfl' : "sum", 'filler' : "sum"})
    agg =agg.filter(agg['count(1)']>=100)

    print('\n\n\n finished group with filter \n\n\n' )

    for d in WordCollection.obj_list: 
		agg=agg.withColumn(d.nomen+'_freq', agg['sum('+d.nomen+')']/agg['sum(wordcount)']) \
            .drop(agg['sum('+d.nomen+')'])

    return agg
