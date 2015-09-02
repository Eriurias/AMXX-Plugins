/**
 * Called when the round ends in favor of a team or a draw.
 *
 * @param team			The winning team.
 * @param gamestarted   Whether there is a composition of both teams.
 */
 enum HnsTeams
 {
    HNS_DRAW,
    HNS_TEAM_T,
    HNS_TEAM_CT
 };
 
 forward hns_round_end(HnsTeams:team, bool: gamestarted);

/**
 * Called at the end of the timer when the CT start acting.
 *
 * @param min_players   Is there a minimum number of players (2).
 */
 forward hns_round_start(bool: min_players);
 
/**
 * Called the duration of the timer. 
 * The feature is useful for creating an informer with a count.
 *
 * @param index         Client index.
 * @param time          Timer seconds.
 */
 forward hns_timer_process(index, time);
 
/**
 * Called when the CT becomes TT
 * thanks to the change of command (native hns_switch_teams()).
 *
 * @param index         Client index.
 */
 forward hns_became_terrorist(index);
 
/**
 * Called when a player from a certain 
 * team is become lonely.
 *
 * @param index         Client index.
 * @param team          Player team.
 */
 forward hns_player_loner(index, HnsTeams:team);

/**
 * The function needs to change the teams interchanged.
 */
 native hns_switch_teams();
 
 /**
 * This function allows you to learn whether there is a composition of both teams.
 */
 native bool:hns_get_gamestarted();
 
 /**
 * This function allows you to learn number of alive players specific team.
 *
 * @param team[10]       Needs a team ("CT" or "TERRORIST").
 */
 native hns_get_aliveplayers(team[10]);