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
package com.queencodemonkey.tlf.madlibs
{
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.SpanElement;
    
    import mx.utils.UIDUtil;

    public class MadLibUtil
    {
		public static const MAD_LIB_BLANK_ID_PREFIX:String = "madlib_blank_";
		
		private static const MAD_LIB_BLANK_ID_REGEXP:RegExp = /madlib_blank_[A-F0-9\-]+/;
		
		public static function generateMadLibBlankId():String
		{
			return MAD_LIB_BLANK_ID_PREFIX + UIDUtil.createUID(); 
		}
		
        public static function isMadLibSpanElement(element:FlowElement):Boolean
        {
			return element is SpanElement && MAD_LIB_BLANK_ID_REGEXP.test(element.id);
        }

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * Constructor.
         *
         * Restricted for type safety.
         */
        public function MadLibUtil(enforcer:StaticEnforcer)
        {
        }
    }
}

/**
 * The StaticEnforcer class is an internal class used for type safety by
 * prohibiting instantiation.
 */
internal class StaticEnforcer
{
}