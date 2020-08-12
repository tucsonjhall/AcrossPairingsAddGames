/*
* The MIT License (MIT)
*
* Copyright (c) 2014. Nicolas Siver (http://siver.im)
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
* documentation files (the "Software"), to deal in the Software without restriction, including without
* limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all copies or substantial portions
* of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
* TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
* CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
* IN THE SOFTWARE.
*/
package com.cactusware.utils {
	
	public class CombinationsCalculator {

		/**
		 * Create all possible combinations with predefined length from the given set of values
		 *
		 * @param values possible values for combinations
		 * @param length combination length
		 * @return array of all possible combinations
		 */

		private static var collectionNames : Array;
		private static var allPairingsSortObjects : Array
		private static var originalPairingSortObjects : Array;
		private static var newPairings : Array;
		private static var pairings : Array;
		private static var startingPairings : Array;
		private static var partialRoundTeamObjectArray : Array;

	
		public static function factorial( n : int ) : Number {
			if ( n < 2 ) {
				return 1;
			}
			return n * factorial( n - 1 );
		}

		public static function permss( xs : Array ) : Array {
			if ( xs.length == 0 ) {
				return [[]];
			}
			return xs.map( function( x : *, index : uint, array : Array ) : * {
				var p : Array = permss( exclude( xs, x ));
				return p.map( function( y : *, _ : uint, __ : Array ) : * {
					var ps : Array = y as Array;
					ps.unshift( x );
					return ps;
				});
			});
		}

		public static function exclude( xs : Array, elem : * ) : Array {
			return xs.filter( function( item : *, index : uint, array : Array ) : Boolean {
				return item != elem;
			});
		}

		public static function getPossiblePairs( values : Array ) : Array {
			var value1 : int;
			var value2 : int;
			var counter : uint = 1;
			var teamIndexObjects : Array = new Array();
			;
			var teamIndexObject : Object;
			for ( var i : uint = 0, leni : uint = values.length; i < leni; i++ ) {
				value1 = values[ i ];
				for ( var x : uint = i + 1; x < values.length; x++ ) {
					value2 = values[ x ];
					teamIndexObject = new Object();
					teamIndexObject.index1 = values[ x ];
					teamIndexObject.index2 = values[ i ];
					teamIndexObjects.push( teamIndexObject );

				}
			}
			return teamIndexObjects;
		}
		

		public static function combinations(values:Array, length:uint):Array {
			var i:uint, j:uint, result:Array, start:Array, end:Array, len:uint, innerLen:uint;
			
			if (length > values.length || length <= 0) {
				return [];
			}
			
			if (length == values.length) {
				return values;
			}
			
			if (length == 1) {
				result = [];
				len = values.length;
				for (i = 0; i < len; ++i) {
					result[i] = [values[i]];
				}
				return result;
			}
			
			result = [];
			len = values.length - length;
			for (i = 0; i < len; ++i) {
				start = values.slice(i, i + 1);
				end = combinations(values.slice(i + 1), length - 1);
				innerLen = end.length;
				for (j = 0; j < innerLen; ++j) {
					result.push(start.concat(end[j]));
				}
			}
			
			return result;
		}
		/**
		 * Do permutations with provided list of values
		 *
		 * @param values list for permutation
		 * @param index current position
		 * @param result array with all possible permutations
		 */
		public static function permutations( values : Array, index : uint, result : Array ) : void {
			var i : uint, len : uint = values.length;
			if ( index == len ) {
				result.push( values.slice());
				return;
			}
			for ( i = index; i < len; ++i ) {
				swap( values, index, i );
				permutations( values, index + 1, result );
				swap( values, index, i );
			}
		}

		/**
		 * Will create all possible combinations from provided subset, with limited length
		 *
		 * @example Start fill:
		 * <listing version="3.0">
		 *     var subsetResult: Array = [];
		 *     myCombinations.subsetFill([0, 1, 2], [], subsetResult, 2);
		 *     trace(subsetResult);
		 * </listing>
		 *
		 * @param values subset of values
		 * @param cursor fill position
		 * @param result subset fill result
		 * @param length max fill length
		 */
		public static function subsetFill( values : Array, cursor : Array, result : Array, length : uint ) : void {
			if ( cursor.length > length ) {
				return;
			}
			if ( cursor.length == length ) {
				result.push( cursor.slice());
			}

			var i : uint, len : uint = values.length;

			for ( i; i < len; ++i ) {
				cursor.push( values[ i ]);
				subsetFill( values, cursor.slice(), result, length );
				cursor.length = cursor.length - 1;
			}
		}

		private static function swap( list : Array, from : uint, to : uint ) : void {
			var temp : * = list[ from ];
			list[ from ] = list[ to ];
			list[ to ] = temp;
		}


		public static function getCombinationsOfTwo( arr : Array, length : int ) : Array {
			var returnPairings : Array = new Array();
			var $allcombos : Array = [];
			var pairings : Array = findCombos( $allcombos, [], arr );
			for ( var i : uint = 0; i < pairings.length; i++ ) {
				if ( pairings[ i ].length == 2 ) {
					returnPairings.push( pairings[ i ]);
				}
			}
			return returnPairings;
		}

		private static function findCombos( $root : Array, $base : Array, $rem : Array ) : Array {
			for ( var i : int = 0; i < $rem.length; i++ ) {
				var a : Array = $base.concat();
				a.push( $rem[ i ]);
				findCombos( $root, a, $rem.slice( i + 1 ));
				if ( a.length > 1 ) {
					$root.push( a );
				}
			}
			return $root;
		}

	}

}
