--[==[
----------------------------------------------------------------------------
conventions:
    curses convention is to place y before x in function parameters, cui
  will use x before y

-- NOTES -------------------------------------------------------------------
- many extended keys aren't reported correctly to curses, avoid using Fxx
  keys.


-- TODO --------------------------------------------------------------------

* better drawing functions
  - organize colors
  - avoid using curses on high level controls
  - use curses interface only for low level drawing
* virtual listbox
* color palette for controls
* mouse support
* documentation
  - luadoc/robodoc
  - tutorial...
* more controls
  - multiline text editor

---------

cgroup:make_vis(pox, posy)
    scroll if needed to make position visible
cgroup:make_vis(window)
    scroll if needed to make window (or part of it) visible

//  Standard command codes

    cmValid         = 0,
    cmQuit          = 1,
    cmError         = 2,
    cmMenu          = 3,
    cmClose         = 4,
    cmZoom          = 5,
    cmResize        = 6,
    cmNext          = 7,
    cmPrev          = 8,
    cmHelp          = 9,

// TWindow Flags masks

    wfMove          = 0x01,
    wfGrow          = 0x02,
    wfClose         = 0x04,
    wfZoom          = 0x08,

-- LOW P. --
* handle interrupt signal?
* know when terminal window has been resized, and resize (at least) the main
  window
* handle process suspend/resume signals? believe this is done by the curses
driver (screen state)
]==]