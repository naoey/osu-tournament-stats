class AddAccuracyToScores < ActiveRecord::Migration[6.0]
  def up
    change_table :match_scores do |t|
      t.column :accuracy, :float
    end

    # calculate accuracies for all existing scores
    MatchScore
      .where(accuracy: nil)
      .all
      .each do |score|
        acc = StatCalculationHelper.calculate_accuracy(score)

        raise ArgumentError, "Accuracy for score with ID #{score.id} is null, migration failed" if acc.nil?

        score.update(accuracy: acc)

        if MatchScore.find(score.id).accuracy.nil?
          raise ArgumentError, "Accuracy for score with ID #{score.id} is null after update, migration failed"
        end
      end

    failed_scores = MatchScore.where(accuracy: nil).select("id").all

    raise ArgumentError, "Accuracy is null for scores #{failed_scores.map(&:id)}; migration failed!" unless failed_scores.empty?

    # set accuracy to be non-null
    change_column :match_scores, :accuracy, :float, null: false
  end

  def down
    remove_column :match_scores, :accuracy
  end
end
