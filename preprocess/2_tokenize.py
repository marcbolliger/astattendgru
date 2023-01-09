from tokenizer import Tokenizer
import pickle
import re
import collections
import sys
#CMDLINE ARGS
#[1] - path to temporary directory
#[2] - path to model directory
datapath = sys.argv[1]
modelpath = sys.argv[2]


#vocab sizes - the authors choose these numbers but don't further elaborate on the reasoning
coms_vocab = 10908
#tdats_vocab = 75000 #Combine tdats and sml into a single tokenizer
sml_vocab = 75000

print("Tokenizing Comments")

comsprfx = datapath+"coms."
comstok = Tokenizer()
comstok.train_from_file(comsprfx+"train",coms_vocab)
comstok.update_from_file(comsprfx+"test")
comstok.update_from_file(comsprfx+"valid")
coms_outfile = modelpath+"coms.tok"
comstok.save(coms_outfile)

print("Tokenizing Code")

tdatsprfx = datapath+"tdats."
tdatstok = Tokenizer()
tdatstok.train_from_file(tdatsprfx+"train",sml_vocab)
tdatstok.update_from_file(tdatsprfx+"test")
tdatstok.update_from_file(tdatsprfx+"valid")

print("Tokenizing AST")

smlprfx = datapath+"smldats."
tdatstok.update_from_file(smlprfx+"train")
tdatstok.update_from_file(smlprfx+"test")
tdatstok.update_from_file(smlprfx+"valid")

sml_outfile = modelpath+"smls.tok"
tdatstok.save(sml_outfile)
