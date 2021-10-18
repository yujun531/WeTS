#!/bin/bash -v

main_dir=../../fairseq-master-underDevelop
data_dir=/dockerdata/zieenyang/corpus/data_fairseq/wmt16_ende
processed=$data_dir/processed_only_para

# generate monolingual data
for lg in en de
do 
    python $main_dir/preprocess.py \
    --task cross_lingual_lm \
    --source-lang $lg \
    --only-source \
    --srcdict $data_dir/vocab.bpe.32000.fairseq \
    --trainpref $data_dir/train.tok.clean.bpe.32000 \
    --validpref $data_dir/newstest2013.tok.bpe.32000 \
    --destdir $processed \
    --workers 20

    for stage in train valid
    do 
        mv $processed/$stage.$lg-None.$lg.bin $processed/$stage.$lg.bin
        mv $processed/$stage.$lg-None.$lg.idx $processed/$stage.$lg.idx
    done
done
wait

# generate bilingual data
python $main_dir/preprocess.py \
  --task xmasked_seq2seq \
  --source-lang en \
  --target-lang de \
  --trainpref ${data_dir}/train.tok.clean.bpe.32000 \
  --validpref ${data_dir}/newstest2013.tok.bpe.32000 \
  --destdir $processed \
  --srcdict ${data_dir}/vocab.bpe.32000.fairseq \
  --tgtdict ${data_dir}/vocab.bpe.32000.fairseq 
