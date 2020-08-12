package com.cactusware.managers {
	import com.cactusware.configurations.PairingsConfiguration;
	import com.cactusware.models.Division;
	import com.cactusware.models.Pairing;
	import com.cactusware.models.Team;
	import com.cactusware.utils.CombinationsCalculator;

	import mx.core.FlexGlobals;

	public class PairingsManager {

		private static const AWAY : int = 0;
		private static const HOME : int = 1;
		private static const EITHER : int = 2;
		private static var currentDivision : Division;
		private static var divisions : Array;
		private static var divisionTeams : Array;
		private static var pairingIndicesForAcrossDivisions : Array;
		public static var divisionObjects : Array;
		private static var oneRoundPairings : Array;
		private static var numberOfGames : int;
		private static var combinations : Array;
		private static var primaryDivision : Division;
		private static var primaryDivisionName : String;
		private static var rounds : int;
		private static var roundsTemplate : Array;
		private static var bIndex : int;
		private static var aIndices : Array;
		private static var bIndices : Array;
		private static var aTeamsNeedPairings : Boolean;
		private static var teamArray : Array;
		private static var hasOddNumberOfGames : Boolean;
		private static var pairings : Array;
		private static var d0Teams : int;
		private static var d1Teams : int;
		private static var numberOfTeamsToRemove : uint;
		private static var teamObjects : Array;
		private static var opponentObjects : Object;
		private static var aDistribution : Array;
		private static var bDistribution : Array;
		private static var gamesRemoved : int;

		public function PairingsManager() {
		}

		private static function flipArrays() : void {
			var newA : int = d1Teams;
			var newB : int = d0Teams;
			d0Teams = newA;
			d1Teams = newB;
		}

		public static function getPairings( $d0Teams : int, $d1Teams : int, $games : int, primaryName : String ) : void {
			divisionObjects = new Array();
			teamObjects = new Array();
			aDistribution = new Array();
			bDistribution = new Array();
			d0Teams = $d0Teams;
			d1Teams = $d1Teams;
			numberOfGames = $games;
			divisions = new Array();
			var team : Team;
			var division : Division;
			var i : uint;
			primaryDivisionName = primaryName;
			if ( d0Teams > d1Teams ) {
				flipArrays()
			}
			hasOddNumberOfGames = ( numberOfGames % 2 == 0 ) ? false : true;
			if ( d0Teams > 0 ) {
				division = new Division();
				division.name = "Division1";
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
				division.name = "Division2";
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
			createAcrossDivision();
			createRotationMatrix();
		}

		private static function createRotationMatrix() : void {
			aIndices = divisions[ 0 ].pairingIndices;
			bIndices = divisions[ 1 ].pairingIndices;
			rounds = Math.ceil( numberOfGames / divisionObjects[ 0 ].teamObjects.length );
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
			tracePairings( pairings );
			numberOfTeamsToRemove = bIndices.length - d0Teams;
			var indicesToRemove : Array = aIndices.concat();
			indicesToRemove.reverse();
			var teamsToRemove : Array = new Array();
			for ( var j : uint = 0; j < numberOfTeamsToRemove; j++ ) {
				teamsToRemove.push( indicesToRemove.shift());
			}
			indicesToRemove.reverse();
			divisionObjects[ 0 ].pairingIndices = indicesToRemove.concat();
			removeTeamsAndGames( teamsToRemove );
			FlexGlobals.topLevelApplication.pairings = pairings;
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

		private static function createAcrossDivision() : void {
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

		private static function removeTeamsAndGames( teamsToRemove : Array ) : void {
			divisionObjects[ 0 ].teamObjects.sortOn( "pairingIndexForAcross", Array.NUMERIC );
			divisionObjects[ 1 ].teamObjects.sortOn( "pairingIndexForAcross", Array.NUMERIC );
			var teamArray : Array = new Array();
			var team : int;
			var pairing : Pairing;
			var teamObject : Object;
			var removed : int = 0;
			trace( FlexGlobals.topLevelApplication.d0Teams );
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
			aDistribution = getDistribution( 0 );
			bDistribution = getDistribution( 1 );
			renumberPairingsWithBIndices();
			tracePairings(pairings);
			for ( var i : int = divisionObjects[ 0 ].teamObjects.length - 1; i > -1; i-- ) {
				if ( teamsToRemove.indexOf( divisionObjects[ 0 ].teamObjects[ i ].pairingIndexForAcross ) != -1 ) {
					divisionObjects[ 0 ].teamObjects.splice( i, 1 );
				}
			}
			aIndices = divisionObjects[0].pairingIndices;
		
			aDistribution = getDistribution( 0 );
			bDistribution = getDistribution( 1 );
			removeGames();
			aDistribution = getDistribution( 0 );
			bDistribution = getDistribution( 1 );
			tracePairings( pairings );

			tracePairings( pairings );
		}

		private static function totalGames( pairingIndexForAcross : int ) : int {
			return teamObjects[ pairingIndexForAcross ].awayCount + teamObjects[ pairingIndexForAcross ].homeCount;
		}

		private static function removeGameFromTeamObject( teamObject : Object, pairing : Pairing ) : Boolean {
			var opponent : Object;
			if ( pairing.visitorIndex == 5 || pairing.homeIndex == 5 ) {
				trace( "Here" );
			}
			if ( aIndices.indexOf( pairing.visitorIndex ) != -1 ) {
				if ( opponentQualifies( teamObject, pairing, AWAY ) == true ) {
					teamObject.awayCount--;
					teamObject.totalCount--;
					opponent = teamObject.opponents[ bIndices.indexOf( pairing.homeIndex )];
					opponent.homeCount--;
					opponent.totalCount--;

					opponentObjects[ bIndices.indexOf( pairing.homeIndex )].homeCount--;
					opponentObjects[ bIndices.indexOf( pairing.homeIndex )].totalCount--;
					opponentObjects[ bIndices.indexOf( pairing.homeIndex )].opponents[ pairing.visitorIndex ].awayCount--;
					opponentObjects[ bIndices.indexOf( pairing.homeIndex )].opponents[ pairing.visitorIndex ].totalCount--;
					return true;
				}
			} else if ( aIndices.indexOf( pairing.homeIndex ) != -1 ) {
				if ( opponentQualifies( teamObject, pairing, HOME ) == true ) {
					teamObject.homeCount--;
					teamObject.totalCount--;
					opponent = teamObject.opponents[ bIndices.indexOf( pairing.visitorIndex )];
					opponent.awayCount--;
					opponent.totalCount--;
					opponentObjects[ bIndices.indexOf( pairing.visitorIndex )].awayCount--;
					opponentObjects[ bIndices.indexOf( pairing.visitorIndex )].totalCount--;
					opponentObjects[ bIndices.indexOf( pairing.visitorIndex )].opponents[ pairing.homeIndex ].homeCount--;
					opponentObjects[ bIndices.indexOf( pairing.visitorIndex )].opponents[ pairing.homeIndex ].totalCount--;
					return true;
				}
			}
			return false;
		}

		///// THIS IS WHERE TO INSERT THE CHECK FOR OPPONENTS

		private static function opponentQualifies( teamObject : Object, pairing : Pairing, position : int ) : Boolean {
			var teamObject : Object;
			var opponent : Object;
			var totalNumberOfGames : int = d0Teams * numberOfGames;
			var maxOpponentGames : int = ( totalNumberOfGames / d1Teams );
			var maxTeamGames : int = numberOfGames;
			var maxHome : int = numberOfGames / 2;
			var opponentAwayCount : int;
			var opponentHomeCount : int;
			var numberOfOpponentsWithoutMaxGames : int = totalNumberOfGames % d1Teams;
			var visitorIndex : int = pairing.visitorIndex;
			var homeIndex : int = pairing.homeIndex;
			if ( position == AWAY ) {
				opponent = opponentObjects[ bIndices.indexOf( homeIndex )];
				trace( opponent.totalCount );
				opponentAwayCount = teamObject.opponents[ bIndices.indexOf( pairing.homeIndex )].awayCount;
				opponentHomeCount = teamObject.opponents[ bIndices.indexOf( pairing.homeIndex )].homeCount - 1; // Projecting what the outcome would be if 1 were subtracted
				if ( Math.abs( opponentHomeCount - opponentAwayCount ) > 1 ) {
					return false;
				}
				if ( opponent.totalCount > maxOpponentGames ) {
					if ( varianceWouldBeLessThanTwoForBIndices( opponent ) == true ) {
						return true;
					}
					return false;
				}
			} else {
				opponent = opponentObjects[ bIndices.indexOf( visitorIndex )];
				opponentAwayCount = teamObject.opponents[ bIndices.indexOf( pairing.visitorIndex )].awayCount - 1;
				opponentHomeCount = teamObject.opponents[ bIndices.indexOf( pairing.visitorIndex )].homeCount; // Projecting what the outcome would be if 1 were subtracted
				if ( Math.abs( opponentHomeCount - opponentAwayCount ) > 1 ) {
					return false;
				}

				trace( opponent.totalCount );
				if ( opponent.totalCount > maxOpponentGames ) {
					if ( varianceWouldBeLessThanTwoForBIndices( opponent ) == true ) {
						return true;
					}
					return false;

				}
			}

			return false;
		}

		private static function varianceWouldBeLessThanTwoForBIndices( opponent : Object ) : Boolean {
			var maximumForBIndices : int = 0;
			var opponentObject : Object;
			for ( var i : uint = 0; i < opponentObjects.length; i++ ) {
				opponentObject = opponentObjects[ i ];
				if ( opponentObject.totalCount > maximumForBIndices ) {
					maximumForBIndices = opponentObject.totalCount;
				}
			}
			var proposedTotal : int = opponent.totalCount - 1;
			if ( maximumForBIndices == 9 ) {
				trace( "here" );
			}
			if ( Math.abs( proposedTotal - maximumForBIndices ) <= 1 ) {
				return true;
			}
			return false;

		}

		private static function removeGames() : void {
			gamesRemoved = 0;
			var teamObject : Object;
			teamObjects = divisionObjects[ 0 ].teamObjects;
			opponentObjects = divisionObjects[ 1 ].teamObjects;

			var existingNumberOfGames : int = teamObjects[ 0 ].awayCount + teamObjects[ 0 ].homeCount;
			var numberOfGamesToRemove : int = existingNumberOfGames - numberOfGames;
			var totalNumberOfGamesToRemove : int = numberOfGamesToRemove * d0Teams;
			aDistribution = getDistribution( 0 );
			bDistribution = getDistribution( 1 );
			for ( var i : uint = 0; i < numberOfGamesToRemove; i++ ) {
				for ( var x : uint = 0; x < aIndices.length; x++ ) {
					teamObject = teamObjects[ x ];
					var isSuccessful : Boolean = removeGame( teamObject );
					if ( isSuccessful == false ) {
						trace( "didn't remove game" );
					}
				}
			}
		}

		private static function removeGame( teamObject : Object ) : Boolean {
			var pairing : Pairing;
			var canRemove : Boolean;
			var awayCount : int = teamObject.awayCount;
			var homeCount : int = teamObject.homeCount;
			var totalCount : int;
			totalCount = teamObject.awayCount + teamObject.homeCount;
			aDistribution = getDistribution( 0 );
			bDistribution = getDistribution( 1 );
			if ( teamObject.pairingIndexForAcross == 5 ) {
				trace( "here" );
			}
			for ( var i : uint = 0; i < pairings.length; i++ ) {

				if ( totalCount > numberOfGames ) {
					pairing = pairings[ i ];
					if ( pairing.visitorIndex == teamObject.pairingIndexForAcross || pairing.homeIndex == teamObject.pairingIndexForAcross ) {

						canRemove = removeGameFromTeamObject( teamObject, pairing );
						if ( canRemove == true ) {
							gamesRemoved++;
							pairings.splice( i, 1 );
							return true;
						} else {
							trace( "couldn't remove game" );
						}
					}
				}
			}
			return false;
		}

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
			for ( var i : uint = 0; i < numberOfGames; i++ ) {
				shortRound = shortRounds[ i ];
				for ( var x : uint = 0; x < shortRound.length; x++ ) {
					pairing = shortRound[ x ];
					trace( pairing.visitorIndex + "," + pairing.homeIndex );
				}
			}
		}

		private static function tracePairings( pairings : Array ) : void {
			var str : String = "------------Start -------------";
			for ( var i : uint = 0; i < pairings.length; i++ ) {
				str += pairings[ i ].visitorIndex + "," + pairings[ i ].homeIndex + "\n";
			}
			FlexGlobals.topLevelApplication.resultsTI.text = str;
			trace( str );
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

//		private static function createOneRoundTwoDivisionPairings() : Array {
//			var numberOfRoundsNeeded : int;
//			if ( primaryDivisionName == "d1" ) {
//				primaryDivision = divisions[ 0 ];
//			} else if ( primaryDivisionName == "d2" ) {
//				primaryDivision = divisions[ 1 ];
//			} else if ( divisions.length > 2 && primaryDivisionName == "d3" ) {
//				primaryDivision = divisions[ 2 ];
//			}
//			return new Array();
//		}

	}
}
