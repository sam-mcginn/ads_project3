.PHONY: all tgt-analysis tgt-elaborate-consumer tgt-elaborate-producer

all: tgt-elaborate-consumer tgt-elaborate-producer

tgt-analysis: ../oisc_pkg.vhd ../oisc.vhd
	ghdl analyze ../oisc_pkg.vhd
	ghdl analyze ../oisc.vhd

tgt-elaborate-producer: tgt-analysis tb_producer.vhd
	ghdl analyze tb_producer.vhd
	ghdl elaborate tb_producer

tgt-elaborate-consumer: tgt-analysis tb_consumer.vhd
	ghdl analyze tb_consumer.vhd
	ghdl elaborate tb_consumer
