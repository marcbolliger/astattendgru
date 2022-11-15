import pickle

#To filter out unwanted functions
#bad_fid = pickle.load(open('autogenfid.pkl', 'rb'))

#Input
comdata = 'com_pp.txt'
good_fid = []
#Output
outfile = './output/dataset.coms' 

fo = open(outfile, 'w')
for line in open(comdata):
    tmp = line.split(',')
    fid = int(tmp[0].strip())
    #Filter
    #if bad_fid[fid]:
    #    continue  
    com = tmp[1].strip()
    com = com.split()
    if len(com) > 13 or len(com) < 3:
    	continue
    com = ' '.join(com)
    fo.write('{}, <s> {} </s>\n'.format(fid, com))
            

fo.close()