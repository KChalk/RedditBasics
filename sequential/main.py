import pandas as pd
from collections import Counter, defaultdict
import re 
#from string import punctuation
from nltk import word_tokenize
from typing import List, Dict
import numpy as np


# add * based prefix matching. 

class WordCollection: 
    obj_list: List['WordCollection'] =[] 
    num_to_obj: Dict[int, 'WordCollection'] ={}
    name_to_obj: Dict[str, 'WordCollection']={}
    vocab_to_objs: Dict[str, List['WordCollection']]=defaultdict(list)

    def __init__(self, num:int, name:str, words:List[str]): 
        self.num=num
        self.name=name
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
   
def filter_posts(filename, outputname, minwords=100):
    sub_list= set(['reddit.com','leagueoflegends', 'gaming', 'DestinyTheGame', 'DotA2', 'ContestofChampions', 'StarWarsBattlefront', 'Overwatch', 'WWII', 'hearthstone', 'wow', 'heroesofthestorm', 'destiny2', 'darksouls3', 'fallout', 'SuicideWatch', 'depression', 'OCD', 'dpdr', 'proED', 'Anxiety', 'BPD', 'socialanxiety', 'mentalhealth', 'ADHD', 'bipolar', 'buildapc', 'techsupport', 'buildapcforme', 'hacker', 'SuggestALaptop', 'hardwareswap', 'laptops', 'computers', 'pcmasterrace', 'relationshps', 'relationship_advice', 'breakups', 'dating_advice', 'LongDistance', 'polyamory', 'wemetonline', 'MDMA', 'Drugs', 'trees', 'opiates', 'LSD', 'tifu', 'r4r', 'AskReddit', 'reddit.com', 'tipofmytongue', 'Life', 'Advice', 'jobs', 'teenagers', 'HomeImprovement', 'redditinreddit', 'FIFA', 'nba', 'hockey', 'nfl', 'mls', 'baseball', 'BokuNoHeroAcademia', 'anime', 'movies', 'StrangerThings'])
    alldata = pd.read_json(filename, lines=True)
    if sub_list!=set():
        alldata=alldata[alldata.subreddit.isin(sub_list)]

    selftext= alldata[alldata['is_self']] 	\
        .loc[:,['id','subreddit','selftext']]

    selftext['selftext']=selftext.transform({'selftext': lambda x: tokenize(x)})#, lambda x: tokenize(x)[1]] })
    selftext[['counter', 'wordcount']] = selftext['selftext'].apply(pd.Series)

    filtered= selftext[selftext['wordcount'] >=minwords] \
            .loc[:,['id','subreddit','counter', 'wordcount']]
    return filtered

def tokenize(s):
    tokens=word_tokenize(s.lower())
    counter=Counter(tokens)

    '''
    s=s.strip().lower()
    wordlist=re.split("[\s;,#]", s)
    for word in wordlist: 
        word=re.sub('^[\W\d]*','',word)
        word=re.sub('[\W\d]*$','',word)
        if word != '':
            tokens.append(word)
    '''
    return counter,len(tokens)


def getfreqs(words_counter): 
    wc_counts=Counter()
    for word, count in words_counter.items(): 
        wcs=WordCollection.match_prefix_to_wcs(word)
        print(wcs)
        for wc in wcs:
            wc_counts[wc]+=count
    return wc_counts

def calculatePosts2(posts):
    posts['dictcounts']=posts.transform({'counter': lambda x: getfreqs(x)})
    
    #new df without self text
    posts=posts.loc[:,['id','subreddit','wordcount','dictcounts']]
    
    #move counts from 'counts' column of dicts to wide columns
    for d in WordCollection.obj_list:
        posts[d.name]=posts.transform({'dictcounts': lambda x: x[d]}) 

    #aggregate per dict counts by subreddit
    grouped = posts.groupby('subreddit')
    subreddits = grouped.agg(sum) #need to collect post counts too
    
    global np #why the fick?
    for d in WordCollection.obj_list:
        subreddits[d.name]=np.divide(subreddits.loc[:,d.name],subreddits.wordcount)
    return subreddits

if __name__ == "__main__":
    filename="RS_2011-01_1000"
    outputname='filtered_'+filename[3:10]
    filtered=filter_posts(filename, outputname)

    WordCollection.wcs_from_file("wordCollections.dic")
    absolutist = ['absolutely', 'all', 'always', 'complete', 'competely','constant', 'constantly', 'definitely', 'entire', 'ever', 'every', 'everyone', 'everything', 'full', 'must', 'never', 'nothing', 'totally','whole']
    WordCollection(0,'absolutist', absolutist)

    abscounts = calculatePosts2(filtered)
    print(abscounts)
#    abscounts.write.csv(output+'.csv', mode='overwrite')
