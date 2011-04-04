package com.queencodemonkey.tlf.bookmarks.events
{
    import flash.events.Event;

    public class LineNumberColumnEvent extends Event
    {

        public static const LINE_NUMBER_SELECTED:String = "lineNumberSelected";

        //------------------------------------------------------------------
        //
        //   P U B L I C    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        public var lineNumber:int;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function LineNumberColumnEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, lineNumber:int = -1)
        {
            super(type, bubbles, cancelable);

            this.lineNumber = lineNumber;
        }
    }
}