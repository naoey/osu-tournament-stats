import React from 'react';

import { Match } from "../../../entities/Match";
import PlayerStatsListTable, { PlayerStatsListTableProps } from "../PlayerStatsListTable";
import './MatchDetails.scss';

export type MatchDetailsProps = {
  match: Match;
  tableProps?: PlayerStatsListTableProps;
}

export function MatchDetails({
  match,
  tableProps,
}: MatchDetailsProps) {
  return (
    <div className="match-details">
      <div className="match-details__info-wrap">
        <div>
          <h2>{match.round_name}</h2>
          {
            match.tournament
              ? null
              // @ts-ignore
              : <h4>{match.tournament.name}</h4>
          }
          <span>
            <span className="text-bold">Winner:&nbsp;</span>
            <span>{match.winning_team.name}</span>
          </span>
        </div>

        <div>
        </div>
      </div>


      <PlayerStatsListTable matchId={match.id} {...tableProps} />
    </div>
  );
}
