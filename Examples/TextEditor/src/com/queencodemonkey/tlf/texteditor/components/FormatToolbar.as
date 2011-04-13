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
package com.queencodemonkey.tlf.texteditor.components
{
    import com.queencodemonkey.tlf.texteditor.events.FormatToolbarEvent;
    import com.queencodemonkey.tlf.texteditor.skins.FormatToolbarSkin;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.engine.FontPosture;
    import flash.text.engine.FontWeight;
    
    import flashx.textLayout.formats.ITextLayoutFormat;
    import flashx.textLayout.formats.TextAlign;
    import flashx.textLayout.formats.TextDecoration;
    
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.core.FlexGlobals;
    import mx.styles.CSSStyleDeclaration;
    
    import spark.components.Button;
    import spark.components.DropDownList;
    import spark.components.ToggleButton;
    import spark.components.supportClasses.SkinnableComponent;
    import spark.events.IndexChangeEvent;

    [Event(name="applyFormat", type="com.queencodemonkey.tlf.texteditor.events.FormatToolbarEvent")]
	[Event(name="blockQuote", type="com.queencodemonkey.tlf.texteditor.events.FormatToolbarEvent")]
    public class FormatToolbar extends SkinnableComponent implements ICommonFormatDisplay
    {

        public static const COLUMN_COUNT_VALUES:Array = [1, 2, 3];

        public static const FONT_FAMILY_VALUES:Array = ["American Typewriter", "Arial",
                                                        "Baskerville", "Courier New",
                                                        "Didot", "Georgia", "Gill Sans",
                                                        "Helvetica Neue", "Minion Pro",
                                                        "Optima", "Times New Roman",
                                                        "Trebuchet", "Verdana"];

        public static const FONT_SIZE_VALUES:Array = [9, 10, 11, 12, 14, 18, 24,
                                                      36, 48, 64, 72, 96, 144];

        public static const LINE_HEIGHT:Number = 120;

        public static const LINE_HEIGHT_VALUES:Array = [.5, .6, .7, .8, .9, 1, 1.1,
                                                        1.2, 1.3, 1.4, 1.5, 2];

        public static const TEXT_ALIGN_VALUES:Array = [TextAlign.LEFT, TextAlign.CENTER,
                                                       TextAlign.RIGHT, TextAlign.JUSTIFY];

        private static const DEFAULT_COLUMN_COUNT:int = 1;

        private static const DEFAULT_FONT_FAMILY:String = "Helvetica Neue";

        private static const DEFAULT_FONT_SIZE:Number = 12;

        private static const DEFAULT_LINE_HEIGHT_INDEX:Number = 5;

        private static const DEFAULT_TEXT_ALIGN:String = TextAlign.LEFT;

        /**
         * @private
         * Static variable to force setting of default styles.
         */
        private static var defaultStylesSet:Boolean = setDefaultStyles();

        //------------------------------------------------------------------
        //
        // P R I V A T E    S T A T I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * @private
         * Sets default values for style properties.
         */
        private static function setDefaultStyles():Boolean
        {
            var toolbarStyles:CSSStyleDeclaration =
                FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.queencodemonkey.tlf.texteditor.components.FormatToolbar");

            if (!toolbarStyles)
            {
                toolbarStyles = new CSSStyleDeclaration();
            }
            toolbarStyles.defaultFactory = function():void
            {
                this.skinClass = FormatToolbarSkin;
            };

            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.queencodemonkey.tlf.texteditor.components.FormatToolbar",
                                                                             toolbarStyles,
                                                                             true);

            return true;
        }

        //------------------------------------------------------------------
        //
        //   S K I N    P A R T S 
        //
        //------------------------------------------------------------------
		
		[SkinPart(required="true")]
		public var blockQuote:Button;

        [SkinPart(required="true")]
        /**
         *
         */
        public var columnCount:DropDownList;

        [SkinPart(required="true")]
        /**
         *
         */
        public var fontFamily:DropDownList;

        [SkinPart(required="true")]
        /**
         *
         */
        public var fontSize:DropDownList;

        [SkinPart(required="true")]
        /**
         *
         */
        public var fontStyle:ToggleButton;

        [SkinPart(required="true")]
        /**
         *
         */
        public var fontWeight:ToggleButton;

        [SkinPart(required="true")]
        /**
         *
         */
        public var lineHeight:DropDownList;

        [SkinPart(required="true")]
        /**
         *
         */
        public var textAlign:DropDownList;

        [SkinPart(required="true")]
        /**
         *
         */
        public var textDecoration:ToggleButton;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function set commonFormat(value:ITextLayoutFormat):void
        {
            if (value)
            {
                fontFamily.selectedItem = value.fontFamily ? value.fontFamily : null;
                fontSize.selectedItem = value.fontSize ? value.fontSize : null;
                fontStyle.selected = value.fontStyle == FontPosture.ITALIC;
                fontWeight.selected = value.fontWeight == FontWeight.BOLD;
                setLineHeight(value.lineHeight);
                textAlign.selectedItem = value.textAlign ? value.textAlign : null;
                textDecoration.selected = value.textDecoration == TextDecoration.UNDERLINE;
            }
            else
            {
                fontFamily.selectedItem = null;
                fontSize.selectedItem = null;
                fontStyle.selected = false;
                fontWeight.selected = false;
                lineHeight.selectedItem = null;
                textAlign.selectedItem = null;
                textDecoration.selected = false;
            }
        }

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var lineHeightDataProvider:IList;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function FormatToolbar()
        {
            super();
        }

        //------------------------------------------------------------------
        //
        //   P R O T E C T E D    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);

            switch (instance)
            {
				case blockQuote:
					blockQuote.addEventListener(MouseEvent.CLICK, blockQuote_clickHandler);
					break;
                case columnCount:
                    columnCount.dataProvider = new ArrayList(COLUMN_COUNT_VALUES);
                    columnCount.selectedItem = DEFAULT_COLUMN_COUNT;
                    columnCount.addEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case fontFamily:
                    fontFamily.dataProvider = new ArrayList(FONT_FAMILY_VALUES);
                    fontFamily.selectedItem = DEFAULT_FONT_FAMILY;
                    fontFamily.addEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case fontSize:
                    fontSize.dataProvider = new ArrayList(FONT_SIZE_VALUES);
                    fontSize.selectedItem = DEFAULT_FONT_SIZE;
                    fontSize.addEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case fontStyle:
                    fontStyle.addEventListener(Event.CHANGE, fontStyle_changeHandler);
                    break;
                case fontWeight:
                    fontWeight.addEventListener(Event.CHANGE, fontWeight_changeHandler);
                    break;
                case lineHeight:
                    lineHeightDataProvider = new ArrayList();
                    var numValues:int = LINE_HEIGHT_VALUES.length;
                    for (var i:int = 0; i < numValues; i++)
                    {
                        lineHeightDataProvider.addItem({label: LINE_HEIGHT_VALUES[i],
                                                           value: (LINE_HEIGHT * LINE_HEIGHT_VALUES[i]).toString() + "%"});
                    }
                    lineHeight.dataProvider = lineHeightDataProvider;
                    lineHeight.selectedIndex = DEFAULT_LINE_HEIGHT_INDEX;
                    lineHeight.addEventListener(IndexChangeEvent.CHANGE, lineHeight_changeHandler);
                    break;
                case textAlign:
                    textAlign.dataProvider = new ArrayList(TEXT_ALIGN_VALUES);
                    textAlign.selectedItem = DEFAULT_TEXT_ALIGN;
                    textAlign.addEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case textDecoration:
                    textDecoration.addEventListener(Event.CHANGE, textDecoration_changeHandler);
                    break;
                default:
                    break;
            }
        }

		private function blockQuote_clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new FormatToolbarEvent(FormatToolbarEvent.BLOCK_QUOTE));
		}

        /**
         * @inheritDoc
         */
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);

            switch (instance)
            {
                case columnCount:
                    columnCount.removeEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case fontFamily:
                    fontFamily.removeEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case fontSize:
                    fontSize.removeEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case fontStyle:
                    fontStyle.removeEventListener(Event.CHANGE, fontStyle_changeHandler);
                    break;
                case fontWeight:
                    fontWeight.removeEventListener(Event.CHANGE, fontWeight_changeHandler);
                    break;
                case lineHeight:
                    lineHeight.removeEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case textAlign:
                    textAlign.removeEventListener(IndexChangeEvent.CHANGE, dropDownList_changeHandler);
                    break;
                case textDecoration:
                    textDecoration.removeEventListener(Event.CHANGE, textDecoration_changeHandler);
                    break;
                default:
                    break;
            }
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function setLineHeight(value:String):void
        {
            var selectedIndex:int = -1;
            if (value)
            {
                var numLineHeight:int = lineHeightDataProvider.length;
                for (var i:int = 0; i < numLineHeight && selectedIndex == -1; i++)
                {
                    if (lineHeightDataProvider.getItemAt(i).value == value)
                        selectedIndex = i;
                }
            }
            lineHeight.selectedIndex = selectedIndex;
        }

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        private function dropDownList_changeHandler(event:IndexChangeEvent):void
        {
            var dropDownList:DropDownList = event.currentTarget as DropDownList;
            dispatchEvent(new FormatToolbarEvent(FormatToolbarEvent.APPLY, false, false, dropDownList.id, dropDownList.selectedItem));
        }

        private function fontStyle_changeHandler(event:Event):void
        {
            dispatchEvent(new FormatToolbarEvent(FormatToolbarEvent.APPLY, false, false, "fontStyle", fontStyle.selected ? FontPosture.ITALIC : FontPosture.NORMAL));
        }

        private function fontWeight_changeHandler(event:Event):void
        {
            dispatchEvent(new FormatToolbarEvent(FormatToolbarEvent.APPLY, false, false, "fontWeight", fontWeight.selected ? FontWeight.BOLD : FontWeight.NORMAL));
        }

        private function lineHeight_changeHandler(event:IndexChangeEvent):void
        {
            dispatchEvent(new FormatToolbarEvent(FormatToolbarEvent.APPLY, false, false, "lineHeight", lineHeight.selectedItem.value));
        }

        private function textDecoration_changeHandler(event:Event):void
        {
            dispatchEvent(new FormatToolbarEvent(FormatToolbarEvent.APPLY, false, false, "textDecoration", textDecoration.selected ? TextDecoration.UNDERLINE : TextDecoration.NONE));
        }
    }
}