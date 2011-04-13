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

    import com.queencodemonkey.tlf.texteditor.events.ImageToolbarEvent;
    import com.queencodemonkey.tlf.texteditor.skins.ImageToolbarSkin;
    
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.core.ClassFactory;
    import mx.core.FlexGlobals;
    import mx.core.IFactory;
    import mx.styles.CSSStyleDeclaration;
    
    import spark.components.List;
    import spark.components.supportClasses.SkinnableComponent;
    import spark.events.IndexChangeEvent;

    [Event(name="insertImage", type="com.queencodemonkey.tlf.texteditor.events.ImageToolbarEvent")]
    public class ImageToolbar extends SkinnableComponent
    {

        [Embed(source="assets/images/BlueBox.png")]
        private var BlueBoxClass:Class;

        [Embed(source="assets/images/Cards.png")]
        private var CardsClass:Class;

        [Embed(source="assets/images/Document.png")]
        private var DocumentClass:Class;

        [Embed(source="assets/images/Patch.png")]
        private var PatchClass:Class;

        [Embed(source="assets/images/Screwdriver.png")]
        private var ScrewdriverClass:Class;

        [Embed(source="assets/images/Whiteboard.png")]
        private var WhiteboardClass:Class;

        private const IMAGE_LIST:Array = ["assets/images/Cards.png", "assets/images/Document.png", "assets/images/Whiteboard.png"];

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
            var imageToolbarStyles:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.queencodemonkey.tlf.texteditor.components.ImageToolbar");

            if (!imageToolbarStyles)
            {
                imageToolbarStyles = new CSSStyleDeclaration();
            }
            imageToolbarStyles.defaultFactory = function():void
            {
				this.skinClass = ImageToolbarSkin;
            };

            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.queencodemonkey.tlf.texteditor.components.ImageToolbar",
                                                                             imageToolbarStyles,
                                                                             true);

            return true;
        }

        //------------------------------------------------------------------
        //
        //   S K I N    P A R T S 
        //
        //------------------------------------------------------------------

        [SkinPart(required="true")]
        /**
         *
         */
        public var imageList:List;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function get imageNames():IList
        {
            return _imageNames;
        }

        /**
         * @private
         */
        public function set imageNames(value:IList):void
        {
            if (value != _imageNames)
            {
                _imageNames = value;
                imageNamesDirty = true;
                invalidateProperties();
            }
        }

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _imageNames:IList = null;

        //------------------------------------------------------------------
        //  D I R T Y    F L A G S 
        //------------------------------------------------------------------

        private var imageNamesDirty:Boolean = false;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function ImageToolbar()
        {
            super();

            construct();
        }

        private function construct():void
        {
			
        }

        //------------------------------------------------------------------
        //
        //   P R O T E C T E D    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override protected function commitProperties():void
        {
            super.commitProperties();

            if (imageNamesDirty)
            {
				if (imageList)
                	imageList.dataProvider = imageNames;
                imageNamesDirty = false;
            }
        }

        /**
         * @inheritDoc
         */
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);

            if (instance == imageList)
            {
				imageList.dataProvider = new ArrayList(IMAGE_LIST);
				imageList.itemRenderer = new ClassFactory(ImageRenderer);
//				imageList.itemRendererFunction = imageListItemRendererFunction;
                imageList.addEventListener(IndexChangeEvent.CHANGE, imageList_changeHandler);
            }
        }

//		private function imageListItemRendererFunction(item:String):IFactory
//		{
//			var factory:ClassFactory = new ClassFactory(
//		}

        /**
         * @inheritDoc
         */
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);

            if (instance == imageList)
            {
                imageList.removeEventListener(IndexChangeEvent.CHANGE, imageList_changeHandler);
            }
        }

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        private function imageList_changeHandler(event:IndexChangeEvent):void
        {
            if (imageList.selectedItem)
                dispatchEvent(new ImageToolbarEvent(ImageToolbarEvent.INSERT_IMAGE, false, false, imageList.selectedItem));
        }
    }
}

