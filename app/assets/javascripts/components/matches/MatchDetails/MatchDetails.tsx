import React from 'react';

import './MatchDetails.scss';
import { IMatch } from "../../../entities/IMatch";
import PlayerStatsListTable, { IPlayerStatsListTableProps } from "../PlayerStatsListTable";

interface MatchDetailsProps {
  match: IMatch;
  tableProps?: IPlayerStatsListTableProps;
}

export default function MatchDetails({
  match,
  tableProps,
}: MatchDetailsProps) {
  return (
    <div className="match-details">
      <div className="match-details__info-wrap">
        <div>
          <h2>{match.round_name}</h2>
          {
            match.tournament === null
              ? null
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
