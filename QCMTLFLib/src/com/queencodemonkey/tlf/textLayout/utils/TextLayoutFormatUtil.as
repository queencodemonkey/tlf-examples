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
package com.queencodemonkey.tlf.textLayout.utils
{

    public class TextLayoutFormatUtil
    {

		public static function isLeafFormat(property:String):Boolean
		{
			switch(property)
			{
				case "color":
				case "fontFamily":
				case "fontSize":
				case "fontStyle":
				case "fontFamily":
				case "fontWeight":
				case "lineHeight":
				case "textDecoration":
					return true;
					break;
				default:
					return false;
					break;
			}
		}
		
		public static function isParagraphFormat(property:String):Boolean
		{
			switch(property)
			{
				case "textAlign":
					return true;
					break;
				default:
					return false;
					break;
			}
		}
		
		public static function isContainerFormat(property:String):Boolean
		{
			
			switch(property)
			{
				case "columnCount":
				case "paddingTop":
				case "paddingBottom":
				case "paddingRight":
				case "paddingLeft":
					return true;
					break;
				default:
					return false;
				break;
			}
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
        public function TextLayoutFormatUtil(enforcer:StaticEnforcer) {}
    }
}

/**
 * The StaticEnforcer class is an internal class used for type safety by
 * prohibiting instantiation.
 */
internal class StaticEnforcer {}