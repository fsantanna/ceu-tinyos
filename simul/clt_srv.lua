local simul = require 'tinyos'

srv = simul.app {
    name = 'server',
    values = {
        Radio_start     = { 1, 1, 0 },
        RADIO_STARTDONE = { 1 },
        PHOTO_READDONE  = { 10, 100, 200, 300 },
    },
    defines = {
        TOS_NODE_ID = 10,
    },
    source = assert(io.open'../samples/srv.ceu'):read'*a',
}

local N = 5
for i=1, N do
    local clt = simul.app {
        name = 'client '..i,
        defines = {
            TOS_NODE_ID = 50+i,
        },
        source = assert(io.open'../samples/clt.ceu'):read'*a',
    }
    _G['clt'..i] = clt
    simul.link(clt,'OUT_RADIO_SEND',  srv,'IN_RADIO_RECEIVE')
    simul.link(srv,'OUT_RADIO_SEND',  clt,'IN_RADIO_RECEIVE')
end
for i=1, N do
    for j=i+1, N do
        local clt1 = _G['clt'..i]
        local clt2 = _G['clt'..j]
        simul.link(clt1,'OUT_RADIO_SEND',  clt2,'IN_RADIO_RECEIVE')
        simul.link(clt2,'OUT_RADIO_SEND',  clt1,'IN_RADIO_RECEIVE')
    end
end

simul.shell()
