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
package com.queencodemonkey.tlf.madlibs.components
{
    import com.queencodemonkey.tlf.madlibs.skins.MadLibSkin;
    import com.queencodemonkey.tlf.madlibs.textLayout.edit.MadLibEditManager;
    import com.queencodemonkey.tlf.madlibs.textLayout.edit.MadLibManager;
    
    import flash.text.engine.FontPosture;
    import flash.text.engine.FontWeight;
    
    import flashx.textLayout.compose.IFlowComposer;
    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.elements.Configuration;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.formats.TextAlign;
    import flashx.textLayout.formats.TextLayoutFormat;
    import flashx.textLayout.formats.WhiteSpaceCollapse;
    import flashx.undo.UndoManager;
    
    import mx.core.FlexGlobals;
    import mx.core.UIComponent;
    import mx.events.ResizeEvent;
    import mx.styles.CSSStyleDeclaration;
    
    import spark.components.supportClasses.SkinnableComponent;

    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#color
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="color", type="uint", format="Color", inherit="yes")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontFamily
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="fontFamily", type="String", inherit="yes")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontSize
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="fontSize", type="Number", format="Length", inherit="yes", minValue="1.0", maxValue="720.0")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontStyle
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="fontStyle", type="String", enumeration="normal,italic", inherit="yes")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontWeight
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="fontWeight", type="String", enumeration="normal,bold", inherit="yes")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#lineHeight
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="lineHeight", type="Object", inherit="yes")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#paddingBottom
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="paddingBottom", type="Number", format="Length", inherit="no", minValue="0.0", maxValue="1000.0")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#paddingLeft
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="paddingLeft", type="Number", format="Length", inherit="no", minValue="0.0", maxValue="1000.0")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#paddingRight
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="paddingRight", type="Number", format="Length", inherit="no", minValue="0.0", maxValue="1000.0")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#paddingTop
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="paddingTop", type="Number", format="Length", inherit="no", minValue="0.0", maxValue="1000.0")]
    /**
     *  @copy flashx.textLayout.formats.ITextLayoutFormat#textAlign
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="textAlign", type="String", enumeration="start,end,left,right,center,justify", inherit="yes")]
    /**
     *
     */
    [Style(name="blankStyleName", type="String", inherit="no")]
    public class MadLib extends SkinnableComponent
    {

        private static const DEFAULT_BLANK_STYLE_NAME:String = "madLibBlankStyle";

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
            var madLibStyles:CSSStyleDeclaration =
                FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.queencodemonkey.tlf.madlibs.components.MadLib");

            if (!madLibStyles)
            {
                madLibStyles = new CSSStyleDeclaration();
            }
            madLibStyles.defaultFactory = function():void
            {
                this.skinClass = MadLibSkin;
                this.blankStyleName = DEFAULT_BLANK_STYLE_NAME;
                this.backgroundColor = 0xFF0000;
                this.color = 0x000000;
                this.fontFamily = "Helvetica Neue, Helvetica, Arial, sans";
                this.fontSize = 24;
                this.fontStyle = FontPosture.NORMAL;
                this.fontWeight = FontWeight.NORMAL;
                this.paddingBottom = 20;
                this.paddingLeft = 20;
                this.paddingRight = 20;
                this.paddingTop = 20;
                this.lineHeight = "240%";
                this.textAlign = TextAlign.LEFT;
            };

            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.queencodemonkey.tlf.madlibs.components.MadLib",
                                                                             madLibStyles,
                                                                             true);

            var madLibBlankStyles:CSSStyleDeclaration =
                FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("." + DEFAULT_BLANK_STYLE_NAME);

            if (!madLibBlankStyles)
            {
                madLibBlankStyles = new CSSStyleDeclaration();
            }
            madLibBlankStyles.defaultFactory = function():void
            {
                this.color = 0x666666;
                this.fontFamily = "Andale Mono, Courier New, Courier, monospace";
                this.fontSize = 14;
                this.fontStyle = FontPosture.NORMAL;
                this.fontWeight = FontWeight.NORMAL;
                this.textAlign = TextAlign.LEFT;
            };

            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("." + DEFAULT_BLANK_STYLE_NAME,
                                                                             madLibBlankStyles,
                                                                             true);

            return true;
        }

        //------------------------------------------------------------------
        //
        //   S K I N    P A R T S 
        //
        //------------------------------------------------------------------

        [SkinPart(required="true")]
        public var madLibContainer:UIComponent;

        [SkinPart(required="true")]
        public var textContainer:UIComponent;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function get data():Object
        {
            return _data;
        }

        /**
         * @private
         */
        public function set data(value:Object):void
        {
            if (value != _data)
            {
                _data = value;
                dataDirty = true;
                invalidateProperties();
            }
        }

        public function get editable():Boolean
        {
            return _editable;
        }

        /**
         * @private
         */
        public function set editable(value:Boolean):void
        {
            if (value != _editable)
            {
                _editable = value;
                editableDirty = true;
                invalidateProperties();
            }
        }

        public function get filledText():String
        {
            return madLibManager.export();
        }

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var configuration:Configuration = null;

        private var controller:ContainerController = null;

        private var madLibManager:MadLibManager = null;

        private var textFlow:TextFlow = null;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _data:Object = null;

        private var _editable:Boolean = false;

        //------------------------------------------------------------------
        //  D I R T Y    F L A G S 
        //------------------------------------------------------------------

        private var dataDirty:Boolean = false;

        private var editableDirty:Boolean = false;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * Constructor.
         */
        public function MadLib()
        {
            super();

            construct();
        }

        public function addBlank(label:String):Boolean
        {
            return madLibManager.addBlank(label) != null;
        }

        /**
         * @inheritDoc
         */
        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);

            var hostFormatDirty:Boolean = false;
            switch (styleProp)
            {
                case "color":
                case "fontFamily":
                case "fontSize":
                case "fontStyle":
                case "fontWeight":
                case "lineHeight":
                case "textAlign":
                    hostFormatDirty = true;
                    break;
                case "blankStyleName":
                    madLibManager.blankStyleName = getStyle("blankStyleName") as String;
                    break;
                default:
                    break;
            }

            if (hostFormatDirty)
            {
                configuration.textFlowInitialFormat[styleProp] =
                    textFlow[styleProp] = getStyle(styleProp);
                textFlow.flowComposer.updateAllControllers();
            }
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

            if (dataDirty)
            {
                if (data is String || data is XML)
                {
                    XML.ignoreWhitespace = false;
                    textFlow = TextConverter.importToFlow(data, TextConverter.TEXT_LAYOUT_FORMAT, configuration);
                }
                else
                {
                    textFlow = new TextFlow();
                }
                setupTextLayout();
                madLibManager.textFlow = textFlow;
            }

            if (dataDirty || editableDirty)
            {
                if (editable)
                    setupInteractionManager();
                else
                    tearDownInteractionManager();
            }

            if (dataDirty)
            {
                dataDirty = false;
            }

            if (editableDirty)
            {
                editableDirty = false;
            }
        }

        /**
         * @inheritDoc
         */
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);

            if (instance == textContainer)
            {
                textContainer.addEventListener(ResizeEvent.RESIZE, textContainer_resizeHandler);
            }
            else if (instance == madLibContainer)
            {
                madLibManager.blankInputContainer = madLibContainer;
            }
        }

        /**
         * @inheritDoc
         */
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);

            if (instance == textContainer)
            {
                textContainer.removeEventListener(ResizeEvent.RESIZE, textContainer_resizeHandler);
            }
            else if (instance == madLibContainer)
            {
                madLibManager.blankInputContainer = null;
            }
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function clearTextContainer():void
        {
            while (textContainer.numChildren > 0)
            {
                textContainer.removeChildAt(0);
            }
        }

        private function construct():void
        {
            madLibManager = new MadLibManager();
            madLibManager.blankStyleName = DEFAULT_BLANK_STYLE_NAME;

            configuration = new Configuration();
            var styleDeclaration:CSSStyleDeclaration =
                FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.queencodemonkey.tlf.madlibs.components.MadLib");
            var initialFormat:TextLayoutFormat = new TextLayoutFormat();
            with (initialFormat)
            {
                color = styleDeclaration.getStyle("color");
                fontFamily = styleDeclaration.getStyle("fontFamily");
                fontSize = styleDeclaration.getStyle("fontSize");
                fontStyle = styleDeclaration.getStyle("fontStyle");
                fontWeight = styleDeclaration.getStyle("fontWeight");
                lineHeight = styleDeclaration.getStyle("lineHeight");
                paddingBottom = styleDeclaration.getStyle("paddingBottom");
                paddingLeft = styleDeclaration.getStyle("paddingLeft");
                paddingRight = styleDeclaration.getStyle("paddingRight");
                paddingTop = styleDeclaration.getStyle("paddingTop");
                textAlign = styleDeclaration.getStyle("textAlign");
                whiteSpaceCollapse = WhiteSpaceCollapse.PRESERVE;
            }
            configuration.textFlowInitialFormat = initialFormat;
            configuration.unfocusedSelectionFormat = configuration.focusedSelectionFormat;

            textFlow = new TextFlow(configuration);
        }

        private function setupInteractionManager():void
        {
            textFlow.interactionManager = new MadLibEditManager(madLibManager, new UndoManager());
        }

        private function setupTextLayout():void
        {
            clearTextContainer();
            controller = new ContainerController(textContainer, textContainer.width, textContainer.height);

            var flowComposer:IFlowComposer = textFlow.flowComposer;
            flowComposer.removeAllControllers();
            flowComposer.addController(controller);
            flowComposer.updateAllControllers();
        }

        private function tearDownInteractionManager():void
        {
            textFlow.interactionManager = null;
        }

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        private function textContainer_resizeHandler(event:ResizeEvent):void
        {
            if (textFlow && controller)
            {
                controller.setCompositionSize(textContainer.width, textContainer.height);
                textFlow.flowComposer.updateAllControllers();
            }
        }
    }
}