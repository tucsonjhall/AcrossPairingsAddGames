package com.cactusware.managers {
	import com.cactusware.models.Division;
	import com.cactusware.models.Pairing;
	import com.cactusware.models.Team;
	
	import mx.core.FlexGlobals;
	import mx.utils.StringUtil;
	
	public class PairingsManager {
		private static const AWAY:int = 0;
		private static const HOME:int = 1;
		private static var d1Teams : int;
		private static var d0Teams : int;
		private static var numberOfGames : int;
		private static var divisions : Array;
		private static var hasOddNumberOfGames : Object;
		private static var aIndices : Array;
		private static var bIndices : Array;
		private static var divisionObjects : Array;
		private static var rounds : Number;
		private static var roundsTemplate : Array;
		private static var numberOfTeamsToRemove : uint;
		private static var currentDivision : Division;
		private static var aDistribution : Array;
		private static var bDistribution : Array;
		private static var opponentObjects : Array;
		private static var teamObjects:Array;
		
		public static var pairings : Array;
		
		public function PairingsManager() {
		}
		
		
		
		public static function getPairings( numberOfDiv_0_teams : int, numberOfDiv_1_teams : int, games : int ) : void {
			d0Teams = numberOfDiv_0_teams;
			d1Teams = numberOfDiv_1_teams;
			var team : Team;
			var division : Division;
			var i : uint;
			
			numberOfGames = games;
			divisions = new Array();
			if ( d0Teams > d1Teams ) {
				flipArrays()
			}
			
			hasOddNumberOfGames = ( numberOfGames % 2 == 0 ) ? false : true;
			
			if ( d0Teams > 0 ) {
				division = new Division();
				division.name = "Division_0";
				
				// d1Teams is not a mistake. Temporarily making both divisions the same size.
				for ( i = 0; i < d1Teams; i++ ) {
					team = new Team();
					team.name = "Team_d1_" + i;
					division.teams.push( team );
				}
				divisions.push( division );
			}
			
			if ( d1Teams > 0 ) {
				division = new Division();
				division.name = "Division_1";
				for ( i = 0; i < d1Teams; i++ ) {
					team = new Team();
					team.name = "Team_d2_" + i;
					division.teams.push( team );
				}
				divisions.push( division );
			}
			
			createDivisionObjects();
			
			aIndices = divisionObjects[ 0 ].pairingIndices.concat();
			bIndices = divisionObjects[ 1 ].pairingIndices.concat();
			
			createOpponentArrays();
			createPairingMatrix();
		}
		
		private static function createDivisionObjects() : void {
			var division : Division;
			var teams : Array;
			var numberOfTeamsInDivision : int;
			var teamObjects : Array = new Array();
			var teamObject : Object;
			divisionObjects = new Array();
			var divisionObject : Object;
			var divisionTeam : Team;
			var exists : Boolean;
			var team : Team;
			var pairingIndexForAcross : int = -1;
			var currentDivision : Division = new Division();
			currentDivision.acrossDivisions = divisions.concat();
			
			var allDivisions : Array = currentDivision.acrossDivisions.concat();
			
			for ( var x : uint = 0; x < currentDivision.acrossDivisions.length; x++ ) {
				division = currentDivision.acrossDivisions[ x ];
				numberOfTeamsInDivision = division.teams.length;
				teams = division.teams.concat();
				var opponent : Object;
				for ( var i : uint = 0; i < teams.length; i++ ) {
					team = teams[ i ];
					pairingIndexForAcross++
						team.pairingIndexForAcross = pairingIndexForAcross;
					division.pairingIndices.push( pairingIndexForAcross );
					
					exists = false;
					for ( var a : uint = 0; a < divisionObjects.length; a++ ) {
						divisionObject = divisionObjects[ a ];
						if ( divisionObject.name == division.name ) {
							teamObject = new Object();
							teamObject.team = team;
							teamObject.pairingIndexForAcross = pairingIndexForAcross;
							teamObject.name = team.name;
							teamObject.awayCount = 0;
							teamObject.homeCount = 0;
							teamObject.totalCount = 0;
							teamObject.opponents = new Array();
							divisionObject.teamObjects.push( teamObject );
							divisionObject.teamObjects.sortOn( "name" );
							divisionObject.teamCount++;
							divisionObject.pairingIndices.push( teamObject.team.pairingIndexForAcross );
							divisionObject.teamObjects.sortOn( "pairingIndexForAcross", Array.NUMERIC );
							exists = true;
						}
					}
					if ( exists == false ) {
						
						teamObject = new Object();
						teamObject.name = team.name;
						teamObject.pairingIndexForAcross = pairingIndexForAcross;
						teamObject.team = team;
						teamObject.awayCount = 0;
						teamObject.homeCount = 0;
						teamObject.totalCount = 0;
						teamObject.opponents = new Array();
						
						divisionObject = new Object();
						divisionObject.division = division;
						divisionObject.name = division.name;
						divisionObject.teamObjects = new Array();
						divisionObject.teamObjects.push( teamObject );
						divisionObject.pairingIndices = new Array();
						divisionObject.pairingIndices.push( teamObject.team.pairingIndexForAcross );
						divisionObject.teamCount = 1;
						divisionObjects.push( divisionObject );
					}
				}
			}
		}
		
		private static function createOpponentArrays() : void {
			var opponent : Object;
			var acrossDivision : Division = new Division();
			for ( var i : uint = 0; i < divisions.length; i++ ) {
				acrossDivision.acrossDivisions.push( divisions[ i ]);
			}
			currentDivision = acrossDivision;
			
			for ( var c : uint = 0; c < divisionObjects[ 0 ].teamObjects.length; c++ ) {
				for ( var b : uint = 0; b < bIndices.length; b++ ) {
					opponent = new Object();
					opponent.pairingIndexForAcross = bIndices[ b ];
					opponent.awayCount = 0;
					opponent.homeCount = 0;
					opponent.totalCount = 0;
					divisionObjects[ 0 ].teamObjects[ c ].opponents.push( opponent );
				}
				
			}
			for ( var cc : uint = 0; cc < divisionObjects[ 1 ].teamObjects.length; cc++ ) {
				for ( var bb : uint = 0; bb < aIndices.length; bb++ ) {
					opponent = new Object();
					opponent.pairingIndexForAcross = aIndices[ bb ];
					opponent.awayCount = 0;
					opponent.homeCount = 0;
					opponent.totalCount = 0;
					divisionObjects[ 1 ].teamObjects[ cc ].opponents.push( opponent );
				}
			}
		}
		
		
		private static function createPairingMatrix() : void {
			aIndices = divisions[ 0 ].pairingIndices;
			bIndices = divisions[ 1 ].pairingIndices;
			rounds = Math.floor( d0Teams / d1Teams );
			var shortRound : Array;
			var pairing : Pairing
			var pairingToMove : int;
			roundsTemplate = new Array();
			for ( var x : uint = 0; x < aIndices.length; x++ ) {
				shortRound = new Array();
				for ( var i : uint = 0; i < aIndices.length; i++ ) {
					pairing = new Pairing();
					if ( x % 2 == 1 ) {
						pairing.visitorIndex = aIndices[ i ];
						pairing.homeIndex = bIndices[ i ];
					} else {
						pairing.visitorIndex = bIndices[ i ];
						pairing.homeIndex = aIndices[ i ];
					}
					updateTeamObjects( pairing );
					shortRound.push( pairing );
				}
				roundsTemplate.push( shortRound );
				pairingToMove = aIndices.shift();
				aIndices.push( pairingToMove );
			}
			if ( rounds > 1 ) {
				roundsTemplate = roundsTemplate.concat( addAdditionalRounds());
			}
			
			traceRounds( roundsTemplate );
			
			pairings = createPairings( roundsTemplate );
			
			numberOfTeamsToRemove = bIndices.length - d0Teams;
			
			var indicesToRemove : Array = aIndices.concat();
			indicesToRemove.reverse();
			var teamsToRemove : Array = new Array();
			for ( var j : uint = 0; j < numberOfTeamsToRemove; j++ ) {
				teamsToRemove.push( indicesToRemove.shift());
			}
			indicesToRemove.reverse();
			
			divisionObjects[ 0 ].pairingIndices = indicesToRemove.concat();
			
			aIndices = divisionObjects[ 0 ].pairingIndices;
			removeTeamsAndGames( teamsToRemove );
			
		}
		
		private static function removeTeamsAndGames( teamsToRemove : Array ) : void {
			var teamArray : Array = new Array();
			var team : int;
			var pairing : Pairing;
			var teamObject : Object;
			
			divisionObjects[ 0 ].teamObjects.sortOn( "pairingIndexForAcross", Array.NUMERIC );
			divisionObjects[ 1 ].teamObjects.sortOn( "pairingIndexForAcross", Array.NUMERIC );
			
			aDistribution = getDistribution( 0 );
			bDistribution = getDistribution( 1 );
			
			opponentObjects = divisionObjects[ 1 ].teamObjects;
			for ( var x : int = pairings.length - 1; x > -1; x-- ) {
				pairing = pairings[ x ];
				if ( teamsToRemove.indexOf( pairing.visitorIndex ) != -1 ) {
					teamObject = divisionObjects[ 0 ].teamObjects[ pairings[ x ].visitorIndex ];
					removeGameFromTeamObject( teamObject, pairing );
					pairings.splice( x, 1 );
				} else if ( teamsToRemove.indexOf( pairing.homeIndex ) != -1 ) {
					teamObject = divisionObjects[ 0 ].teamObjects[ pairing.homeIndex ];
					removeGameFromTeamObject( teamObject, pairing );
					pairings.splice( x, 1 );
				}
			}
			
			for ( var i : int = divisionObjects[ 0 ].teamObjects.length - 1; i > -1; i-- ) {
				if ( teamsToRemove.indexOf( divisionObjects[ 0 ].teamObjects[ i ].pairingIndexForAcross ) != -1 ) {
					divisionObjects[ 0 ].teamObjects.splice( i, 1 );
				}
			}
			for ( var a : int = aIndices.length - 1; a > -1; a-- ) {
				if ( teamsToRemove.indexOf( aIndices[ a ]) != -1 ) {
					aIndices.splice( a, 1 );
				}
			}
			
			renumberPairingsWithBIndices();
			
			teamObjects = divisionObjects[ 0 ].teamObjects;
			opponentObjects = divisionObjects[1].teamObjects;
			
			addGames( numberOfGames - aDistribution[ 0 ].totalCount );
			
			aDistribution = getDistribution( 0 );
			bDistribution = getDistribution( 1 );
			tracePairings( pairings );
		}
		
		private static function addGames( games : int ) : void {
			var pairing : Pairing
			var shortRound : Array;
			var gamesNeeded : int = games;
			var aIndex : int = 0;
			var bIndex : int = 0;
			var indexToMove : int;
			gamesNeeded = Math.abs( games );
			if ( rounds < 2 ) {
				pairings = new Array();
				gamesNeeded = numberOfGames;
			}
			for ( var x : uint = 0; x < gamesNeeded; x++ ) {
				for ( var i : uint = 0; i < aIndices.length; i++ ) {
					if ( x % 2 == 0 ) {
						aIndex = aIndices[ i ];
						pairing = new Pairing();
						pairing.visitorIndex = aIndex;
						pairing.homeIndex = bIndices[ bIndex ];
						pairings.push( pairing );
						bIndex++
						if ( bIndex > bIndices.length - 1 ) {
							bIndex = 0;
						}
					} else {
						aIndex = aIndices[ i ];
						pairing = new Pairing();
						pairing.homeIndex = aIndex;
						pairing.visitorIndex = bIndices[ bIndex ];
						pairings.push( pairing );
						bIndex++
						if ( bIndex > bIndices.length - 1 ) {
							bIndex = 0;
						}
					}
					trace( pairing.visitorIndex + "," + pairing.homeIndex );
					
				}
				indexToMove = aIndices.shift();
				aIndices.push( indexToMove );
			}
			tracePairings( pairings );
		}
		
		//		private static function totalGames( pairingIndexForAcross : int ) : int {
		//			return teamObjects[ pairingIndexForAcross ].awayCount + teamObjects[ pairingIndexForAcross ].homeCount;
		//		}
		
		private static function removeGameFromTeamObject( teamObject : Object, pairing : Pairing ) : Boolean {
			if ( pairing.visitorIndex == 5 || pairing.homeIndex == 5 ) {
				trace( "Here" );
			}
			if ( aIndices.indexOf( pairing.visitorIndex ) != -1 ) {
				if ( opponentQualifies( pairing, AWAY ) == true ) {
					teamObject.awayCount--;
					teamObject.totalCount--;
					teamObject.opponents[ bIndices.indexOf( pairing.homeIndex )].homeCount--;
					teamObject.opponents[ bIndices.indexOf( pairing.homeIndex )].totalCount--;
					opponentObjects[ bIndices.indexOf( pairing.homeIndex )].homeCount--;
					opponentObjects[ bIndices.indexOf( pairing.homeIndex )].totalCount--;
					opponentObjects[ bIndices.indexOf( pairing.homeIndex )].opponents[ pairing.visitorIndex ].awayCount--;
					opponentObjects[ bIndices.indexOf( pairing.homeIndex )].opponents[ pairing.visitorIndex ].totalCount--;
					return true;
				}
			} else if ( aIndices.indexOf( pairing.homeIndex ) != -1 ) {
				if ( opponentQualifies( pairing, HOME ) == true ) {
					teamObject.homeCount--;
					teamObject.totalCount--;
					teamObject.opponents[ bIndices.indexOf( pairing.visitorIndex )].awayCount--;
					teamObject.opponents[ bIndices.indexOf( pairing.visitorIndex )].totalCount--;
					opponentObjects[ bIndices.indexOf( pairing.visitorIndex )].awayCount--;
					opponentObjects[ bIndices.indexOf( pairing.visitorIndex )].totalCount--;
					opponentObjects[ bIndices.indexOf( pairing.visitorIndex )].opponents[ pairing.homeIndex ].homeCount--;
					opponentObjects[ bIndices.indexOf( pairing.visitorIndex )].opponents[ pairing.homeIndex ].totalCount--;
					return true;
				}
			}
			return false;
		}
		
		private static function opponentQualifies( pairing : Pairing, position : int ) : Boolean {
			
			var opponent : Object;
			var totalNumberOfGames : int = d0Teams * numberOfGames;
			var maxOpponentGames : int = ( totalNumberOfGames / d1Teams );
			var maxTeamGames : int = numberOfGames;
			var maxHome : int = numberOfGames / 2;
			var numberOfOpponentsWithoutMaxGames : int = totalNumberOfGames % d1Teams;
			var visitorIndex : int = pairing.visitorIndex;
			var homeIndex : int = pairing.homeIndex;
			if ( position == HOME ) {
				
				// 
				opponent = opponentObjects[ bIndices.indexOf( visitorIndex )];
				if ( opponent.totalCount > maxOpponentGames ) {
					return true;
				}
			} else {
				opponent = opponentObjects[ bIndices.indexOf( homeIndex )];
				if ( opponent.totalCount > maxOpponentGames ) {
					return true;
				}
			}
			
			return false;
		}
		
		//		private static function removeGames() : void {
		//			var teamObject : Object;
		//			teamObjects = divisionObjects[ 0 ].teamObjects;
		//			opponentObjects = divisionObjects[ 1 ].teamObjects;
		//			for ( var a : uint = 0; a < opponentObjects.length; a++ ) {
		//				opponentObjects[ a ].pairingIndexForAcross -= numberOfTeamsToRemove;
		//			}
		//			var existingNumberOfGames : int = teamObjects[ 0 ].awayCount + teamObjects[ 0 ].homeCount;
		//			var numberOfGamesToRemove : int = existingNumberOfGames - numberOfGames;
		//			aDistribution = getDistribution( 0 );
		//			bDistribution = getDistribution( 1 );
		//
		//			for ( var i : uint = 0; i < numberOfGamesToRemove; i++ ) {
		//				for ( var x : uint = 0; x < aIndices.length; x++ ) {
		//					teamObject = teamObjects[ x ];
		//					var isSuccessful : Boolean = removeGame( teamObject );
		//					if ( isSuccessful == false ) {
		//						trace( "didn't remove game" );
		//					}
		//				}
		//			}
		//		}
		//
		//		private static function removeGame( teamObject : Object ) : Boolean {
		//			var candidates : Array;
		//			var pairing : Pairing;
		//			var canRemove : Boolean;
		//			var awayCount : int = teamObject.awayCount;
		//			var homeCount : int = teamObject.homeCount;
		//			var totalCount : int;
		//			totalCount = teamObject.awayCount + teamObject.homeCount;
		//			aDistribution = getDistribution( 0 );
		//			bDistribution = getDistribution( 1 );
		//			if ( teamObject.pairingIndexForAcross == 5 ) {
		//				trace( "here" );
		//			}
		//
		//			// Maybe sort opponents here and locate pairings that involve the opponent with the most need for removing a pairing
		//			candidates = orderOpponentsByTotals();
		//			for ( var i : uint = 0; i < pairings.length; i++ ) {
		//
		//				if ( totalCount > numberOfGames ) {
		//					pairing = pairings[ i ];
		//					if ( pairing.visitorIndex == teamObject.pairingIndexForAcross || pairing.homeIndex == teamObject.pairingIndexForAcross ) {
		//
		//						canRemove = removeGameFromTeamObject( teamObject, pairing );
		//						if ( canRemove == true ) {
		//							pairings.splice( i, 1 );
		//							return true;
		//						} else {
		//							trace( "couldn't remove game" );
		//						}
		//					}
		//				}
		//			}
		//			return false;
		//		}
		
		///// THIS IS WHERE TO INSERT THE CHECK FOR OPPONENTS
		
		//		private static function orderOpponentsByTotals() : Array {
		//			var returnArray : Array = opponentObjects.concat();
		//			returnArray.sortOn( "totalCount", Array.NUMERIC | Array.DESCENDING );
		//			return returnArray;
		//
		//		}
		
		private static function getDistribution( division : int ) : Array {
			var distribution : Array = new Array();
			var teamObject : Object;
			var teamObjects : Array = new Array();
			var indices : Array = ( division == 0 ) ? aIndices : bIndices;
			for ( var i : uint = 0; i < indices.length; i++ ) {
				teamObject = new Object();
				if ( division == 1 ) {
					teamObject.pairingIndexForAcross = bIndices[ i ];
				} else {
					teamObject.pairingIndexForAcross = i;
				}
				teamObject.awayCount = 0;
				teamObject.homeCount = 0;
				teamObject.totalCount = 0;
				teamObjects.push( teamObject );
				for ( var x : uint = 0; x < pairings.length; x++ ) {
					if ( pairings[ x ].visitorIndex == teamObject.pairingIndexForAcross ) {
						teamObject.awayCount++;
						teamObject.totalCount++;
					}
					if ( pairings[ x ].homeIndex == teamObject.pairingIndexForAcross ) {
						teamObject.homeCount++;
						teamObject.totalCount++;
					}
				}
			}
			return teamObjects;
		}
		
		private static function renumberPairingsWithBIndices() : void {
			var pairing : Pairing;
			var teamObject : Object;
			var teamObjects : Array = divisionObjects[ 0 ].teamObjects;
			//			aIndices.reverse();
			//			for ( var j : uint = 0; j < numberOfTeamsToRemove; j++ ) {
			//				aIndices.shift();
			//			}
			//			aIndices.reverse();
			for ( var i : uint = 0; i < pairings.length; i++ ) {
				pairing = pairings[ i ];
				if ( bIndices.indexOf( pairing.visitorIndex ) != -1 ) {
					pairing.visitorIndex -= numberOfTeamsToRemove;
				}
				if ( bIndices.indexOf( pairing.homeIndex ) != -1 ) {
					pairing.homeIndex -= numberOfTeamsToRemove;
				}
			}
			for ( var x : uint = 0; x < bIndices.length; x++ ) {
				bIndices[ x ] -= numberOfTeamsToRemove;
			}
			for ( var a : uint = 0; a < aIndices.length; a++ ) {
				teamObject = teamObjects[ aIndices[ a ]];
				for ( var b : uint = 0; b < teamObject.opponents.length; b++ ) {
					teamObject.opponents[ b ].pairingIndexForAcross -= numberOfTeamsToRemove;
				}
			}
			for ( var c : uint = 0; c < divisionObjects[ 1 ].teamObjects.length; c++ ) {
				divisionObjects[ 1 ].teamObjects[ c ].pairingIndexForAcross -= numberOfTeamsToRemove;
			}
			
		}
		
		//		private static function createRoundTemplatesForUnequalDivisions() : void {
		//			aIndices = divisions[ 0 ].pairingIndices;
		//			bIndices = divisions[ 1 ].pairingIndices;
		//			var shortRound : Array;
		//			var pairing : Pairing
		//			var pairingToMove : int;
		//			roundsTemplate = new Array();
		//			bIndex = 0;
		//
		//			for ( var a : uint = 0; a < numberOfGames; a++ ) {
		//				for ( var x : uint = 0; x < aIndices.length; x++ ) {
		//					shortRound = new Array();
		//					for ( var i : uint = 0; i < aIndices.length; i++ ) {
		//						pairing = new Pairing();
		//						if ( x % 2 == 1 ) {
		//							pairing.visitorIndex = aIndices[ i ];
		//							pairing.homeIndex = bIndices[ bIndex ];
		//						} else {
		//							pairing.visitorIndex = bIndices[ bIndex ];
		//							pairing.homeIndex = aIndices[ i ];
		//						}
		//						updateTeamObjects( pairing );
		//						shortRound.push( pairing );
		//						bIndex++;
		//						if ( bIndex > bIndices.length - 1 ) {
		//							bIndex = 0;
		//						}
		//
		//					}
		////					tracePairings( shortRound );
		//					roundsTemplate.push( shortRound );
		//					pairingToMove = aIndices.shift();
		//					aIndices.push( pairingToMove );
		//				}
		//			}
		//			var teamObject : Object;
		//			var totalGames : int;
		////			aTeamsNeedPairings = true;
		////			while ( aTeamsNeedPairings ) {
		////				for ( var j : uint = 0; j < divisionObjects[ 0 ].teamObjects.length; j++ ) {
		////					teamObject = divisionObjects[ 0 ].teamObjects[ j ];
		////					totalGames = teamObject.awayCount + teamObject.homeCount;
		////					if ( totalGames < numberOfGames ) {
		////						pairing = getNextPairing( teamObject );
		////						if ( pairing != null ) {
		////
		////						}
		////					}
		////				}
		////
		////			}
		////			if ( rounds > 1 ) {
		////				continueAddingGames();
		////			}
		//			traceRounds( roundsTemplate );
		//		}
		
		private static function createPairings( template : Array ) : Array {
			var pairings : Array = new Array();
			var shortRound : Array;
			for ( var i : uint = 0; i < template.length; i++ ) {
				shortRound = template[ i ];
				for ( var x : uint = 0; x < shortRound.length; x++ ) {
					pairings.push( shortRound[ x ]);
				}
			}
			return pairings;
		}
		
		private static function continueAddingGames() : void {
			
		}
		
		public static function updateTeamObjects( pairing : Pairing ) : void {
			var i : int;
			var x : int;
			var opponent : Object;
			var visitorIndex : int = pairing.visitorIndex;
			var homeIndex : int = pairing.homeIndex;
			var abort : Boolean;
			if ( divisionObjects[ 0 ].pairingIndices.indexOf( visitorIndex ) != -1 ) {
				divisionObjects[ 0 ].teamObjects[ visitorIndex ].awayCount++;
				divisionObjects[ 0 ].teamObjects[ visitorIndex ].totalCount++;
				
				for ( i = 0; i < divisionObjects[ 0 ].teamObjects[ visitorIndex ].opponents.length; i++ ) {
					opponent = divisionObjects[ 0 ].teamObjects[ visitorIndex ].opponents[ i ];
					if ( opponent.pairingIndexForAcross == homeIndex ) {
						opponent.homeCount++;
						opponent.totalCount++;
						break;
					}
				}
				for ( x = 0; x < divisionObjects[ 1 ].teamObjects.length; x++ ) {
					if ( abort == true ) {
						abort = false;
						break;
					}
					abort = false;
					if ( divisionObjects[ 1 ].teamObjects[ x ].pairingIndexForAcross == homeIndex ) {
						divisionObjects[ 1 ].teamObjects[ x ].homeCount++;
						divisionObjects[ 1 ].teamObjects[ x ].totalCount++;
						for ( i = 0; i < divisionObjects[ 1 ].teamObjects[ x ].opponents.length; i++ ) {
							opponent = divisionObjects[ 1 ].teamObjects[ x ].opponents[ i ];
							if ( opponent.pairingIndexForAcross == visitorIndex ) {
								opponent.awayCount++;
								opponent.totalCount++;
								abort = true;
								break;
							}
						}
						
					}
				}
			} else {
				divisionObjects[ 0 ].teamObjects[ homeIndex ].homeCount++;
				divisionObjects[ 0 ].teamObjects[ homeIndex ].totalCount++;
				for ( i = 0; i < divisionObjects[ 0 ].teamObjects[ homeIndex ].opponents.length; i++ ) {
					opponent = divisionObjects[ 0 ].teamObjects[ homeIndex ].opponents[ i ];
					if ( opponent.pairingIndexForAcross == visitorIndex ) {
						opponent.awayCount++;
						opponent.totalCount++;
						break;
					}
				}
				for ( x = 0; x < divisionObjects[ 1 ].teamObjects.length; x++ ) {
					if ( abort == true ) {
						abort = false;
						break;
					}
					abort = false;
					if ( divisionObjects[ 1 ].teamObjects[ x ].pairingIndexForAcross == visitorIndex ) {
						divisionObjects[ 1 ].teamObjects[ x ].awayCount++;
						divisionObjects[ 1 ].teamObjects[ x ].totalCount++;
						for ( i = 0; i < divisionObjects[ 1 ].teamObjects[ x ].opponents.length; i++ ) {
							opponent = divisionObjects[ 1 ].teamObjects[ x ].opponents[ i ];
							if ( opponent.pairingIndexForAcross == homeIndex ) {
								opponent.homeCount++;
								opponent.totalCount++;
								abort = true;
								break;
							}
						}
						
					}
				}
			}
		}
		
		//
		//		private static function getTeamByPairingIndex( index : int ) : void {
		//
		//		}
		//
		//		private static function addAdditionalRoundsForUneven() : Array {
		//			return new Array()
		//		}
		
		private static function addAdditionalRounds() : Array {
			var pairing : Pairing;
			var returnArray : Array = new Array();
			var nextRound : Array = new Array();
			var additionalRounds : int = rounds - 1;
			var tempTemplate : Array = roundsTemplate.concat();
			var lastTemplate : Array = tempTemplate.concat();
			var newRound : Array;
			var shortRound : Array;
			for ( var i : uint = 0; i < additionalRounds; i++ ) {
				newRound = lastTemplate.concat();
				newRound = flip( newRound );
				returnArray = returnArray.concat( newRound );
				lastTemplate = newRound.concat();
			}
			return returnArray;
		}
		
		private static function flipPairing( pairing : Pairing ) : void {
			var v : int = pairing.visitorIndex;
			var h : int = pairing.homeIndex;
			pairing.visitorIndex = h;
			pairing.homeIndex = v;
		}
		
		private static function flip( template : Array ) : Array {
			var shortRound : Array;
			var pairing : Pairing;
			var a : int;
			var b : int;
			
			var returnArray : Array = new Array();
			for ( var i : uint = 0; i < template.length; i++ ) {
				shortRound = new Array();
				returnArray.push( shortRound );
				for ( var x : uint = 0; x < template[ i ].length; x++ ) {
					pairing = new Pairing();
					a = template[ i ][ x ].visitorIndex;
					b = template[ i ][ x ].homeIndex;
					pairing.visitorIndex = b;
					pairing.homeIndex = a;
					updateTeamObjects( pairing );
					shortRound.push( pairing );
				}
			}
			return returnArray;
		}
		
		private static function traceRounds( shortRounds : Array ) : void {
			var shortRound : Array;
			var pairing : Pairing;
			for ( var i : uint = 0; i < shortRounds.length; i++ ) {
				shortRound = shortRounds[ i ];
				for ( var x : uint = 0; x < shortRound.length; x++ ) {
					pairing = shortRound[ x ];
					trace( pairing.visitorIndex + "," + pairing.homeIndex );
				}
			}
		}
		
		private static function tracePairings( pairings : Array ) : void {
			var str : String = "";
			for ( var i : uint = 0; i < pairings.length; i++ ) {
				str += pairings[ i ].visitorIndex + "," + pairings[ i ].homeIndex + "\n";
			}
			trace( str );
			FlexGlobals.topLevelApplication.resultsTI.text = StringUtil.trim( str );
			
		}
		
		private static function removePairingsWithinDivisions( combinations : Array ) : void {
			var combination : Array;
			for ( var i : int = combinations.length - 1; i > -1; i-- ) {
				combination = combinations[ i ];
				if ( combinationIsFromSameDivision( combination ) == true ) {
					combinations.splice( i, 1 );
				}
			}
		}
		
		private static function combinationIsFromSameDivision( combination : Array ) : Boolean {
			var visitorDivision : Division = getTeamDivision( combination[ AWAY ]);
			var homeDivision : Division = getTeamDivision( combination[ HOME ]);
			if ( visitorDivision.GUID == homeDivision.GUID ) {
				return true;
			}
			
			return false;
		}
		
		private static function getTeamDivision( index : int ) : Division {
			var divisionObject : Object;
			for ( var i : uint = 0; i < divisionObjects.length; i++ ) {
				divisionObject = divisionObjects[ i ];
				if ( divisionObject.pairingIndices.indexOf( index ) != -1 ) {
					return divisionObject.division;
				}
			}
			return null;
		}
		
		private static function flipArrays() : void {
			var newA : int = d1Teams;
			var newB : int = d0Teams;
			d0Teams = newA;
			d1Teams = newB;
		}
		
	}
}
