import pandas as pd
from collections import Counter, defaultdict
import re 
#from string import punctuation
from nltk import word_tokenize
from typing import List, Dict
import numpy as np

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
            WordCollection.vocab_to_objs[w].append(self)

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
    
def getdicts(filename):
    boundarycount=0
    with open(filename) as file:
        for line in file:
            line=line.strip()
            if line=='%':
                boundarycount+=1
                continue
            if boundarycount==1: #in list of dicionary names and codes
                line=line.split('\t')
                WordCollection(line[0],line[1],[])

            if boundarycount==2: #in list of words followed by list of dicts they belong to 
                line=line.split('\t')
                word=line[0]
                if word[-1]=='*': #remove *'s-- program will not distinguish between words and prefixes
                    word=word[:-1]
                
                for col_num in line[1:]:
                    obj= WordCollection.num_to_obj[col_num]
                    WordCollection.vocab_to_objs[word].append(obj)
            if boundarycount>2: 
                print('\n\n\n')
                print('error in reading dicts')
                print('\n\n\n')
    return WordCollection

def adddict(dictnum,dictname,wordlist):
    WordCollection(dictnum,dictname,wordlist)
    #    absolutist = set(['absolutely', 'all', 'always', 'complete', 'competely','constant', 'constantly', 'definitely', 'entire', 'ever', 'every', 'everyone', 'everything', 'full', 'must', 'never', 'nothing', 'totally','whole'])

def getfreqs(counter): 
    counts=Counter()
    for word, count in counter.items():
        i=len(word)
        while i>0:
            try:
                for d in WordCollection.vocab_to_objs[word[:i]]:
                    counts[d]+=count
                i=0 
            except KeyError: 
                i-=1	
    return counts

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

    global DICTIONARIES
    getdicts("LIWC2007_updated.dic")
    absolutist = ['absolutely', 'all', 'always', 'complete', 'competely','constant', 'constantly', 'definitely', 'entire', 'ever', 'every', 'everyone', 'everything', 'full', 'must', 'never', 'nothing', 'totally','whole']
    WordCollection(0,'absolutist', absolutist)

    abscounts = calculatePosts2(filtered)
    print(abscounts)
#    abscounts.write.csv(output+'.csv', mode='overwrite')
