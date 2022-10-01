require 'csv'

require_relative "creature"

class Job
  attr_reader :folder

  def initialize(folder:)
    @folder = folder
  end

  def creatures
    @creatures ||= Dir["#{self.folder}/**"]
      .map { |f| Creature.new(folder: f) }
  end

  def creatures_lookup
    @creatures_lookup ||= self.creatures
      .map { |c| [c.name, c] }.to_h
  end

  def bio_csv_path
    "#{self.folder}/../bios.csv"
  end

  def bio_csv
    @bio_image_ocr ||= begin
      unless File.file?(self.bio_csv_path)
        CSV.open(self.bio_csv_path, 'w', headers: ['name','bio']) do |csv|
          self.creatures.each do |c|
            csv << [c.name, c.bio_text]
          end
        end
      end

      CSV.read(self.bio_csv_path, headers: true)
    end
  end
end