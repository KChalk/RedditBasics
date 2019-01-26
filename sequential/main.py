

#filter posts
import pandas as pd
#from collections import defaultdict
#import csv
#import re 
#from string import punctuation
from nltk import word_tokenize
   
def filter_posts(filename, outputname, minwords=0):        
    sub_list= set(['reddit.com','leagueoflegends', 'gaming', 'DestinyTheGame', 'DotA2', 'ContestofChampions', 'StarWarsBattlefront', 'Overwatch', 'WWII', 'hearthstone', 'wow', 'heroesofthestorm', 'destiny2', 'darksouls3', 'fallout', 'SuicideWatch', 'depression', 'OCD', 'dpdr', 'proED', 'Anxiety', 'BPD', 'socialanxiety', 'mentalhealth', 'ADHD', 'bipolar', 'buildapc', 'techsupport', 'buildapcforme', 'hacker', 'SuggestALaptop', 'hardwareswap', 'laptops', 'computers', 'pcmasterrace', 'relationshps', 'relationship_advice', 'breakups', 'dating_advice', 'LongDistance', 'polyamory', 'wemetonline', 'MDMA', 'Drugs', 'trees', 'opiates', 'LSD', 'tifu', 'r4r', 'AskReddit', 'reddit.com', 'tipofmytongue', 'Life', 'Advice', 'jobs', 'teenagers', 'HomeImprovement', 'redditinreddit', 'FIFA', 'nba', 'hockey', 'nfl', 'mls', 'baseball', 'BokuNoHeroAcademia', 'anime', 'movies', 'StrangerThings'])
    alldata = pd.read_json(filename, lines=True)
    if sub_list!=set():
        alldata=alldata[alldata.subreddit.isin(sub_list)]

    selftext= alldata[alldata['is_self']] 	\
        .loc[:,['id','subreddit','selftext']]

    selftext.transform({'selftext': lambda x: tokenize(x)})
    selftext['wordcount']= len(selftext['selftext'])

    filtered= selftext[selftext['wordcount'] >=minwords] \
            .loc[:,['id','subreddit','tokens', 'wordcount']]

    print(filtered)
    return filtered

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
'''

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

    vectors.write.json(output+'.json', mode='overwrite')
    return vectors
'''
if __name__ == "__main__":
    filename="smalldataset.txt"
    output='filtered_'+filename[-14:-4]

    filter_posts(filename, output)
    #convertToVec()
