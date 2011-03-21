////////////////////////////////////////////////////////////////////////////////
//
//  Copyright © Houghton Mifflin Harcourt 2010.  
//  All Rights Reserved.  
//  This software and documentation is the confidential and proprietary  
//  information of Houghton Mifflin Harcourt ("Confidential Information").  
//  You shall not disclose such Confidential Information and shall use  
//  it only in accordance with the terms of the license agreement you  
//  entered into with Houghton Mifflin Harcourt.  
//  Unauthorized reproduction or distribution of this Confidential  
//  Information, or any portion of it, may result in severe civil and  
//  criminal penalties.  
//
////////////////////////////////////////////////////////////////////////////////
package com.queencodemonkey.tlf.components.page
{
    import flash.display.Sprite;

    import flashx.textLayout.container.ContainerController;

    import mx.core.IDataRenderer;
    import mx.core.IVisualElement;
    import mx.core.UIComponent;
    import mx.events.ResizeEvent;

    public class PageComponentItemRenderer extends UIComponent implements IDataRenderer
    {

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        public function get data():Object
        {
            return controller;
        }

        /**
         * @private
         */
        public function set data(value:Object):void
        {
            var newContainerController:ContainerController = value is ContainerController ? value as ContainerController : null;
            if (newContainerController != data)
            {
                tearDownContainer();
				container = null;
				
                controller = newContainerController;
				
				if ( controller )
				{
					container = controller.container;
					setupContainer();
				}
				
                dataDirty = true;
                invalidateProperties();
            }

        }

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var controller:ContainerController = null;

        private var container:Sprite = null;

        private var dataDirty:Boolean = false;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function PageComponentItemRenderer()
        {
            super();

            construct();
        }

        private function construct():void
        {
            addEventListener(ResizeEvent.RESIZE, resizeHandler);
        }

        private function resizeHandler(event:ResizeEvent):void
        {
            sizeContainer();
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
                dataDirty = false;
            }
        }

        private function sizeContainer():void
        {
            container.width = width;
            container.height = height;
        }

		private function setupContainer():void
		{
			if(container)
			{
				addChild(container);
				sizeContainer();
			}
		}
		
        private function tearDownContainer():void
        {
            if (container)
                removeChild(container);
        }
    }
}