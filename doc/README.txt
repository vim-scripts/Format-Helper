    This script provides some format effects, such as, document information statistics, list addition and deletion, text block addition and deletion, head line and foot line addition, matched parenthesis auto-completion and omni-completion enhancement. Both this functions can be used for plain text, or process comment for programming file.

***************************************************************************
*   NOTE: Effects in this file were made by "format_helper.vim" plugin.   *
***************************************************************************


MAINPAGE
========

    http://franksun.blogbus.com/logs/30678478.html

    Most of these effects are illustrated by some figures in above page.


FUNCTIONS OUTLINE
=================

1. Doc-info statistics
----------------------

    A command is provided to calculate doc-info, such as, number of characters (both with space and no-space), words, and lines (both empty and nonempty) within your selected area.

        ++++++++++++++++++++++++++
        +   :[range]Statistics   +
        ++++++++++++++++++++++++++

* Detail:

    [range] - same usage as in command line, such as, '%' (or "0,$") means whole file, '.' means current line, etc. If range field is empty, then it counts current line's information by default.

* NOTE: 

    (1) It can handle wide (2 or 3 bytes) character languages (for instance, Chinese, Japanese, Korean, etc.). If &encoding=='utf-8', width of wide character is set to 3, otherwise 2.
    (2) As my tests show, precision of this function is better than Win-Word's "word count" tool, which only identifies space as word-delimiter, meanwhile, this script takes all non-word characters (\W) into account. Unfortunately, it is not as efficient as win-word when handles large files (to handle a file with 30,000 lines, win-word costs about 3.5 seconds, and this script costs about 9 seconds).

2. Number list addition and deletion
------------------------------------

    This is a cute function:

    (1) You can set the format of item head to any style as you wish, such as, (1), [1], {1}, 1., -1-, etc. And them can also be deleted by this script.
    (2) It will acquire the head of the last item in previous number list, and make the first index of current list continue with the previous list's last index.

    Two command are provided:

        ++++++++++++++++++++++++++++++++++++++
        +   :[range]AddNumberList {format}   +
        +   :[range]DelNumberList {format}   +
        ++++++++++++++++++++++++++++++++++++++

* Detail:

    [range] - same usage as Statistics.
    {format} - includes three segments: a presegment, a number or a question mark ('?'), and a postsegment. You can set presegment and postsegment to any style you like. If a number is located in between presegment and postsegment, then the first index of number list is set to the number. Otherwise, if a qusetion mark is located there, script will automatically acquire the last index of previous number list and continue with it.

* NOTE:

    (1) If a question mark is neighboring with numbers in a style, the index will be continued with previous list.

* Control parameters: some global variables to control format effect

    g:format_list_ceil (default 0): empty lines from above content to the first line of list.
    g:format_list_floor (default 0): empty lines form the last line of list to below content.
    g:format_list_indent (default 0): indent spaces from beginning of current line to the item head.
    g:format_list_max_scope (default 100): max lines to search the last index of previous number list from assigned line number.

* Example:

    Here are selected lines:

#line
         ######################
    1    #   this is line1    #
    2    #   this is line2    #
         #   ......           #
   10    #   this is line10   #
         ######################

If you input a command:

    :1,5 AddNumberList (1)

they will be changed to:

#line
        #########################
    1   #   (1) this is line1   #
        #    ......             #
    5   #   (5) this is line2   #
    6   #   this is line6       #
        #    ......             #
   10   #   this is line10      #
        #########################

If you want to continue this list across 3 lines, add line 9 and line 10 to the number list, you have two approaches--first one, you can assign the index of new head manually, for instance, you've already remembered the last index of previous number list was '5', then you should input:

    :9,10 AddNumberList (6)

the other one is to call script to automatically acquire a continuous index, here, you should use question mark '?':

    :9,10 AddNumberList (?)

both of these two approaches will change file to below:

#line
        #########################
    1   #   (1) this is line1   #
        #    ......             #
    5   #   (5) this is line2   #
    6   #   this is line6       #
    7   #   this is line7       #
    8   #   this is line8       #
    9   #   (6) this is line9   #
   10   #   (7) this is line10  #
        #########################

If you want to cancel this number list, just input a command:

    :1,10 DelNumberList (?)

3. Auto-fit alignation
----------------------

    Vim provide three commands to align line, ":left", ":center" and ":right", but these command cannot align line to correct position. It is caused by some factors, such as, different size of users' screen, different size of gvim's window, and the most important factor--the 'textwidth' is equal to 80 by default. 
    Here provide three new commands that auto-fit different size of screen or window, and handle alignations correctly.

        ++++++++++++++++++++++
        +   :[range]Left     +
        +   :[range]Center   +
        +   :[range]Right    +
        ++++++++++++++++++++++

4. Enumerate list addition and deletion
---------------------------------------

    Same usage as :AddNumberList and :DelNumberList, but I think these commands will be more useful than number list, as you can set comments for any programming language, means, set the head style to comment leader.

        ++++++++++++++++++++++++++++++++++++++++
        +   :[range]AddEnumerateList {style}   +
        +   :[range]DelEnumerateList {style}   +
        ++++++++++++++++++++++++++++++++++++++++

* NOTE: 

    (1) This fucntion can be used to add or delete comments for any programming languages

* Control parameters: some global variables to control format effect

    g:format_list_ceil (default 0): empty lines from above content to the first line of list.
    g:format_list_floor (default 0): empty lines form the last line of list to below content.
    g:format_list_indent (default 0): indent spaces from beginning of current line to the item head.

* Example:

    If you want to comment lines from line 19 to line 82 in a C++ file, just input:
    
    :19,82 AddEnumerateList //

input below command to cancel this enumerate list:

    :19,82 DelEnumerateList //

5. Text block addition and deletion
-----------------------------------

    Two commands are provided to add text block with selected lines and delete this block.

        +++++++++++++++++++++++++++++++++++++
        +   :[range]AddTextBlock {symbol}   +
        +   :[range]DelTextBlock {symbol}   +
        +++++++++++++++++++++++++++++++++++++

* Detail:

    [range] - same usage as Statistics.
    {symbol} - script will use this character to construct boundary.

* NOTE: 

    (1) This fucntion can be commbined with enumerate list to add or delete comment for any programming language.

* Control parameters: some global variables to control format effect

    g:format_block_ceil (default 0): empty lines from above content to the boundary of block.
    g:format_block_floor (default 0): empty lines form the boundary of block to below content.
    g:format_block_indent (default 0): indent spaces from beginning of current line to left boundary of block.
    g:format_block_internal_ceil (default 0): empty lines form ceiling boundary to the first line of block contents.
    g:format_block_internal_floor (default 0):  empty line form the last line of block contents to floor boundary.

* Example:

    Here are lines to add in text block:

########################
#   (above contents)   #
#                      #
#   block contents     #
#                      #
#   (below contents)   #
########################

If you input a command (all parameters by default values):

    :'<,'> AddTextBlock *

then we have:

##############################
#   (above contents)         #
#                            #
#   **********************   #
#   *   block contents   *   #
#   **********************   #
#                            #
#   (below contents)         #
##############################

if you input:

    :'<,'> DelTextBlock *

we have:

##############################
#   (above contents)         #
#                            #
#                            #
#       block contents       #
#                            #
#                            #
#   (below contents)         #
##############################

6. Auto-complete matched pair parenthesis
-----------------------------------------

    Here provides a function to auto-complete match parenthesis in your insert mode. It completes matched pairs of (), [], {}, and <>, and immediately move cursor leftwards to the middle of pairs. If you input anti-parenthesis, it will erase the extra one.
    
7. Headline and footline addition
---------------------------------

    Do you see previous line? Yeah, it was made by command ":footlilne-". It will draw head line or foot line whose length is equal to current line.

        ++++++++++++++++++++++++++++++++++++++++
        +   :[line number] HeadLine {symbol}   +
        +   :[line number] FootLine {symbol}   +
        ++++++++++++++++++++++++++++++++++++++++

* Detail:

    {symbol} - head line or foot line are made with this character.

8. Enhance completion function
------------------------------
    
    Here provides a function to binding completion with <Tab> key. When you hit <Tab> in the insert mode, it will complete your content by your omni-function if you set your own omni-function, otherwise, the nearest known words or keywords of the dictionary you set (control by option 'dictionary') will be completed.


INSTALLATION
============

(1) For Unix: Copy "format_helper.vim" script to $HOME/.vim/plugin/

(2) For Windows: Copy "format_helper.vim" to $VIM\vimfiles\plugin\


UPGRADE
=======

By default, GetLatestVimScripts plugin is included in Vim installation package, whose version is higher than v7. So you can use it to auto-download the newest package. Add below line into file "GetLatestVimScripts.dat":

                           2418 1 format-helper

and use this command ":GetLatestVimScripts" to upgrade it.


**************
*   NOTICE   *
**************

    When you want to hack this script, please make sure that the option 'Tlist_Show_Menu' is closed (set its value as 0) if "Taglist" plugin was installed in your Vim. Otherwise, it will popup an annoyed message "E792: Empty menu name".
