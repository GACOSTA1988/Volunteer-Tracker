class Project
    attr_accessor :title, :id
    def initialize(attributes)
        @title = attributes[:title]
        @id = attributes[:id].to_i
    end
    def save
        @id = DB.exec("INSERT INTO projects (title) VALUES ('#{@title}') RETURNING id;").first.fetch("id").to_i
        self
    end
    def update(new_attrs)
        @title = new_attrs[:title]
        DB.exec("UPDATE projects SET title = '#{@title}' WHERE id = #{@id};")
    end
    def delete
        DB.exec("DELETE FROM projects WHERE id = #{@id};")
        DB.exec("DELETE FROM volunteers WHERE project_id = #{@id};")
    end
    def volunteers
      Volunteer.find_by_project(@id)
    end
    def ==(compare)
        (@title == compare.title)
    end

    #class methods
    def self.all
        DB.exec("SELECT * FROM projects;").map { |project| Project.new(self.keys_to_sym(project)) }
    end
    def self.clear
        DB.exec("DELETE FROM projects *;")
    end
    def self.find(search_id)
        attributes = DB.exec("SELECT * FROM projects WHERE id = #{search_id};").first
        Project.new(self.keys_to_sym(attributes))
    end

    # private
    def self.keys_to_sym(str_hash)
        str_hash.reduce({}) do |acc, (key, val)|
            acc[key.to_sym] = (['id'].include? key) ? val.to_i : val
            acc
        end
    end
end
