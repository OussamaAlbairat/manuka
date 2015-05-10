NODE ?= manuka
REBAR ?= "rebar"
CONFIG ?= "priv/sys.config"
RUN := erl -pa ebin -pa deps/*/ebin -smp enable -config ${CONFIG}

all:
	${REBAR} get-deps compile

quick:
	${REBAR} skip_deps=true compile

quick_clean:
	${REBAR} skip_deps=true clean

clean:
	${REBAR} clean

run: quick
	if [ -n "${NODE}" ]; then ${RUN} -name ${NODE}
	else ${NODE} -s manuka; \
	fi
