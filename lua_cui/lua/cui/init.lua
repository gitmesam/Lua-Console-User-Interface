--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tngd@mega.ist.utl.pt)
$Id: __core.lua,v 1.6 2004/08/27 08:19:45 tngd Exp $
--------------------------------------------------------------------------]]

-- module defenition
module('cui', package.seeall)

-- load curses module
require 'curses'

-- include base functions and objects
require 'cui.core'
require 'cui.object'
require 'cui.event'
require 'cui.point'
require 'cui.rect'
require 'cui.view'
require 'cui.group'
require 'cui.program'

