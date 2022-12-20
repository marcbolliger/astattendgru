import tokenizer
import pickle
import sys
import uuid


#CMDLINE ARGS
#[1] - path to temporary directory
#[2] - path to model directory
datapath = sys.argv[1]
modelpath = sys.argv[2]

comlen = 13
#sdatlen = 20 # average is 8 functions per file
tdatlen = 100
smllen = 100 # average is 870

def save(obj, filename):
	pickle.dump(obj, open(filename, 'wb'))


coms_trainf = datapath+'coms.train'
coms_valf = datapath+'coms.valid'
coms_testf = datapath+'coms.test'
comlen = comlen


tdats_trainf = datapath+'tdats.train'
tdats_valf = datapath+'tdats.valid'
tdats_testf = datapath+'tdats.test'

sml_trainf = datapath+'smldats.train'
sml_valf = datapath+'smldats.valid'
sml_testf = datapath+'smldats.test'


comstok = tokenizer.Tokenizer().load(modelpath+'coms.tok')
smlstok = tokenizer.Tokenizer().load(modelpath+'smls.tok')
tdatstok = smlstok # same tokenizer for smls and tdats so we can share embedding
sdatstok = tdatstok # also same tokenizer for tdats and sdats

com_train = comstok.texts_to_sequences_from_file(coms_trainf, maxlen=comlen)
com_val = comstok.texts_to_sequences_from_file(coms_valf, maxlen=comlen)
com_test = comstok.texts_to_sequences_from_file(coms_testf, maxlen=comlen)
tdats_train = tdatstok.texts_to_sequences_from_file(tdats_trainf, maxlen=tdatlen)
tdats_val = tdatstok.texts_to_sequences_from_file(tdats_valf, maxlen=tdatlen)
tdats_test = tdatstok.texts_to_sequences_from_file(tdats_testf, maxlen=tdatlen)

smldats_train = smlstok.texts_to_sequences_from_file(sml_trainf, maxlen=smllen)
smldats_val = smlstok.texts_to_sequences_from_file(sml_valf, maxlen=smllen)
smldats_test = smlstok.texts_to_sequences_from_file(sml_testf, maxlen=smllen)



assert len(com_train) == len(tdats_train)
assert len(com_val) == len(tdats_val)
assert len(com_test) == len(tdats_test)

out_config = {'tdatvocabsize': tdatstok.vocab_size, 'comvocabsize': comstok.vocab_size, 
            'smlvocabsize': smlstok.vocab_size, 'tdatlen': tdatlen, 'comlen': comlen,
            'smllen': smllen}

dataset = {'ctrain': com_train, 'cval': com_val, 'ctest': com_test, 
	   'dtrain': tdats_train, 'dval': tdats_val, 'dtest': tdats_test,
           'strain': smldats_train, 'sval': smldats_val, 'stest': smldats_test,
	   'comstok': comstok, 'tdatstok': tdatstok, 'smltok': smlstok,
           'config': out_config}

save(dataset, modelpath+'dataset.pkl')
