class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.string :title
      t.text :content
      t.integer :rating
      t.references :provider, foreign_key: true
      t.references :service, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
