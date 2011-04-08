////////////////////////////////////////////////////////////////////////////////
//
//  Copyright © 2011, Huyen Tue Dao 
//  All rights reserved. 
// 
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met: 
//      * Redistributions of source code must retain the above copyright 
//        notice, this list of conditions and the following disclaimer. 
//      * Redistributions in binary form must reproduce the above copyright 
//        notice, this list of conditions and the following disclaimer in the 
//        documentation and/or other materials provided with the distribution. 
//      * Neither the name of Huyen Tue Dao nor the names of other contributors 
//        may be used to endorse or promote products derived from this software 
//        without specific prior written permission. 
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
//  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL HUYEN TUE DAO BE LIABLE FOR 
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY 
//  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
//  SUCH DAMAGE. 
//
////////////////////////////////////////////////////////////////////////////////
package com.queencodemonkey.tlf.bookmarks.components
{
    import com.queencodemonkey.tlf.bookmarks.components.supportClasses.Bookmark;
    
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;
    
    import mx.core.FTETextField;
    
    import spark.core.SpriteVisualElement;

    public class BookmarkColumn extends SpriteVisualElement
    {
        private static const DEFAULT_BACKGROUND_COLOR:uint = 0xCCCCCC;

        private static const DEFAULT_BOOKMARK_BORDER_COLOR:uint = 0x163C7B;

        private static const DEFAULT_BOOKMARK_FILL_COLOR:uint = 0x82B3F5;

        private static const DEFAULT_BOOKMARK_WIDTH:Number = 8;

        private static const DEFAULT_LINE_HEIGHT:Number = 16.8;

        //------------------------------------------------------------------
        //
        //   P U B L I C    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        public var backgroundColor:uint;

        public var bookmarkBorderColor:uint;

        public var bookmarkFillColor:uint;

        public var bookmarkWidth:Number;

        public var bookmarks:Dictionary;

        public var lineHeight:Number;
		
		private var bookmarkTooltip:FTETextField;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function BookmarkColumn()
        {
            super();

            construct();
        }

        public function addBookmark(lineNumber:int, description:String):void
        {
            var bookmark:Bookmark = new Bookmark(lineNumber, description);
            var bookmarkSprite:Sprite = createBookmarkSprite();
            bookmark.sprite = bookmarkSprite;
            bookmarks[lineNumber] = bookmark;
            invalidateParentSizeAndDisplayList();
        }

        public function removeBookmark(lineNumber:int):void
        {
            var bookmark:Bookmark = bookmarks[lineNumber];
            removeChild(bookmark.sprite);
            delete bookmarks[lineNumber];
        }

        /**
         * Called during the validation pass by the Flex LayoutManager via
         * the layout object.
         * @param width
         * @param height
         * @param postLayoutTransform
         *
         */
        override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void
        {
            super.setLayoutBoundsSize(width, height, postLayoutTransform);

            layoutBookmarks();
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function construct():void
        {
            bookmarks = new Dictionary(true);

            backgroundColor = DEFAULT_BACKGROUND_COLOR;
            bookmarkBorderColor = DEFAULT_BOOKMARK_BORDER_COLOR;
            bookmarkFillColor = DEFAULT_BOOKMARK_FILL_COLOR;
            bookmarkWidth = DEFAULT_BOOKMARK_WIDTH;
            lineHeight = DEFAULT_LINE_HEIGHT;
			
			bookmarkTooltip = new FTETextField();
        }
		
        private function createBookmarkSprite():Sprite
        {
            var sprite:Sprite = new Sprite();
            var graphics:Graphics = sprite.graphics;
            graphics.clear();
            graphics.lineStyle(2, bookmarkBorderColor);
            graphics.beginFill(bookmarkFillColor);
            graphics.drawRect(0, 0, bookmarkWidth, lineHeight);
            graphics.endFill();
            sprite.cacheAsBitmap;
            return sprite;
        }

        private function layoutBookmarks():void
        {
            var sprite:Sprite = null;
            for each (var bookmark:Bookmark in bookmarks)
            {
                sprite = bookmark.sprite;
                sprite.x = (width - bookmarkWidth) >> 1;
                sprite.y = (bookmark.lineNumber - 1) * lineHeight;
                if (!sprite.parent)
				{
                    addChild(sprite);
				}
            }
        }
    }
}