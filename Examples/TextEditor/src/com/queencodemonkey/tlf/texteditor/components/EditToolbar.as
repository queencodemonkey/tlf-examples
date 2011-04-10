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
    import com.queencodemonkey.tlf.texteditor.events.EditToolbarEvent;
    import com.queencodemonkey.tlf.texteditor.skins.EditToolbarSkin;
    
    import flash.events.MouseEvent;
    
    import mx.core.FlexGlobals;
    import mx.styles.CSSStyleDeclaration;
    
    import spark.components.Button;
    import spark.components.TextInput;
    import spark.components.supportClasses.SkinnableComponent;
    import spark.events.TextOperationEvent;
	
	[Event(name="find", type="com.queencodemonkey.tlf.texteditor.events.EditToolbarEvent")]
	[Event(name="replace", type="com.queencodemonkey.tlf.texteditor.events.EditToolbarEvent")]
    public class EditToolbar extends SkinnableComponent
    {

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
                FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.queencodemonkey.tlf.texteditor.components.EditToolbar");

            if (!toolbarStyles)
            {
                toolbarStyles = new CSSStyleDeclaration();
            }
            toolbarStyles.defaultFactory = function():void
            {
				this.skinClass = EditToolbarSkin;
            };

            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.queencodemonkey.tlf.texteditor.components.EditToolbar",
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
        /**
         *
         */
        public var findButton:Button;

        [SkinPart(required="true")]
        /**
         *
         */
        public var findTextInput:TextInput;

        [SkinPart(required="true")]
        /**
         *
         */
        public var replaceButton:Button;

        [SkinPart(required="true")]
        /**
         *
         */
        public var replaceTextInput:TextInput;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function EditToolbar()
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
                case findButton:
                    findButton.addEventListener(MouseEvent.CLICK, findButton_clickHandler);
                    break;
                case findTextInput:
                    findTextInput.addEventListener(TextOperationEvent.CHANGE, findTextInput_changeHandler);
                    break;
                case replaceButton:
                    replaceButton.addEventListener(MouseEvent.CLICK, replaceButton_clickHandler);
                    break;
                case replaceTextInput:
                    break;
                default:
                    break;
            }
        }

        /**
         * @inheritDoc
         */
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);

            switch (instance)
            {
                case findButton:
                    findButton.removeEventListener(MouseEvent.CLICK, findButton_clickHandler);
                    break;
                case findTextInput:
                    findTextInput.removeEventListener(TextOperationEvent.CHANGE, findTextInput_changeHandler);
                    break;
                case replaceButton:
                    replaceButton.removeEventListener(MouseEvent.CLICK, replaceButton_clickHandler);
                    break;
                case replaceTextInput:
                    break;
                default:
                    break;
            }
        }

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        private function findButton_clickHandler(event:MouseEvent):void
        {
            dispatchEvent(new EditToolbarEvent(EditToolbarEvent.FIND, false, false, findTextInput.text));
        }

        private function findTextInput_changeHandler(event:TextOperationEvent):void
        {
            findButton.enabled = replaceButton.enabled = findTextInput.text.length > 0;
        }

        private function replaceButton_clickHandler(event:MouseEvent):void
        {
            dispatchEvent(new EditToolbarEvent(EditToolbarEvent.REPLACE, false, false, findTextInput.text, replaceTextInput.text));
        }
    }
}