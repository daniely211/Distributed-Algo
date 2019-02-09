
# distributed algorithms, n.dulay, 25 jan 19
# coursework 1, broadcast algorithms
# Makefile, v2

VERSION = 1
PEERS = 5

# call main (for non-docker single node), main_net (for docker), main_ssh (for lan ssh)
MAIN     = Broadcast2.main
MAIN_NET = Broadcast2.main_net
MAIN_SSH = Broadcast2.main_ssh

PROJECT  = da347
NETWORK  = $(PROJECT)_network

LOCAL	 = mix run --no-halt -e $(MAIN) $(VERSION) $(PEERS)
COMPOSE  = MAIN=$(MAIN_NET) VERSION=$(VERSION) PEERS=$(PEERS) docker-compose -p $(PROJECT)
SSH      = MAIN=$(MAIN_SSH) VERSION=$(VERSION) PEERS=$(PEERS)

# non-docker compile and run
compile:
	mix compile

run:
	$(LOCAL)
	@echo ----------------------

clean:
	mix clean

runall:
	make run VERSION=1
	make run VERSION=2
	make run VERSION=3
	make run VERSION=4
	make run VERSION=5
	make run VERSION=6

# docker compile and run
dcompile dockercompile:
	mix clean
	docker run -it --rm -v "$(PWD)":/project -w /project elixir:alpine mix compile

drun dockerrun:
	@make dockercompile
	@make up
	@echo ----------------------

# ssh commands
ssh_run:
	mix clean
	mix compile
	@make ssh_up

ssh_up:
	$(SSH) ./ssh.sh up

ssh_down:
	$(SSH) ./ssh.sh down

ssh_show:
	$(SSH) ./ssh.sh show

# more docker commands
up:
	$(COMPOSE) up

down:
	$(COMPOSE) down
	@make show

kill:
	docker rm -f `docker ps -a -q`
	docker network rm $(NETWORK)

show:
	@echo ----------------------
	@make ps
	@echo ----------------------
	@make network

show2:
	@echo ----------------------
	@make ps2
	@echo ----------------------
	@make network

ps:
	docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'

ps2:
	docker ps -a -s

network net:
	docker network ls

inspect:
	docker network inspect $(NETWORK)

netrm:
	docker network rm $(NETWORK)

conrm:
	docker rm $(ID)
