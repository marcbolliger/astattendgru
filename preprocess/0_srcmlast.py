import pickle
import json
import os
import sys
import gzip
from zipfile import ZipFile
import datetime

#Cmdline arguments:
#[1] - path to dataset/attack
#[2] - path to output/processed data
datapath = sys.argv[1] #'/itet-stor/marcbo/net_scratch/astgrudata/test/test.jsonl'
outpath = sys.argv[2] #'./itet-stor/marcbo/net_scratch/astgrudata/test/srcml.seq'
srcmlpath = '/itet-stor/marcbo/net_scratch/srcml/build/bin/srcml'

#Write the resulting asts into a pickle
#Code and coms directly to a file
#Path to test/train/val as input..

#Helper for writing a dictionary to a file
def write(data, filename):
    with open(filename, 'w') as outfile:
        for fid, string in data.items():
            outfile.write("{}, {}\n".format(fid, string))

def write_coms(data, filename):
    with open(filename, 'w') as outfile:
        for fid, string in data.items():
            outfile.write("{}, <s> {} </s>\n".format(fid, string))

#Helper for storing a dictionary as a pickle
def save_pickle(data, filename):
    with open(filename,'wb') as outfile:
        pickle.dump(data, outfile)


coms = dict() #Comments
tdats = dict() #Code
smldats = dict() #ASTS


print("Building the ASTs")

#Function that converts the dataset stored in mlmfc to a dataset expected by the preprocessing scripts
#outtype is either train,val,test
def preprocess(jsonpath, outpath, outtype):

    print("Building for: "+outtype, flush=True)

    with gzip.open(jsonpath+outtype+"/"+outtype+".jsonl.gz", 'r') as f:
    #Get the AST for each method in the dataset using srcml on the cmdline
        for fid, line in enumerate(f) :
            data = json.loads(line)
            com = data["docstring"]
            code = data["code"]


            if(fid % 20000 == 0 and fid != 0):
                print(fid, flush=True)
                ct = datetime.datetime.now()
                print("current time: ", ct, flush=True)


            with open("./temp.java", "w") as tempfile:
                tempfile.write(code)

            #Pass tempfile to srcml on the cmdline
            os.system( srcmlpath + " ./temp.java > ./ast.xml")

            with open("./ast.xml", "r") as astfile:
                ast = astfile.read().rstrip()
                smldats[fid] = ast

            #Remove commas from comments
            com = com.strip()
            com = com.split(',')
            com = ' '.join(com)
            com = com.split()
            com = ' '.join(com)
            coms[fid] = com

            tdats[fid] = code

        #Write output to file
        write_coms(coms, outpath+"coms."+outtype)
        save_pickle(tdats, outpath+"tdats."+outtype+".pkl")
        #Dump AST in pickle
        save_pickle(smldats, outpath+"smldats."+outtype+".pkl")

#Do the preprocessing for train/test/val each
preprocess(datapath, outpath, "test")
preprocess(datapath, outpath, "train")
preprocess(datapath, outpath, "valid")
