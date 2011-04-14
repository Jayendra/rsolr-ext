module RSolr::Ext::Response::Groups

  class GroupItem
    attr_reader :name, :numFound, :start, :docs

    def initialize name, numFound, start, docs
      @name, @numFound, @start, @docs = name, numFound, start, docs
    end
  end

  class GroupField
    attr_reader :name, :numFound, :items

    def initialize name, numFound, items
      @name, @numFound, @items = name, numFound, items
    end
  end

  # @response.groups.each do |group|
  #   group.name
  #   group.items
  # end
  # "caches" the result in the @groups instance var
  def groups
    @groups ||= (
    group_fields.map do |(group_field_name, group_items)|
      group_by_field_name(group_field_name)
    end
    )
  end

  # pass in a group field name and get back a group field instance
  def group_by_field_name(name)
    items = []
    group_items = group_fields[name]
    group_items['groups'].each do |group|
      docs = group['doclist']['docs']
      docs.each { |doc| doc.extend RSolr::Ext::Doc }
      items << GroupItem.new(group['groupValue'], group['doclist']['numFound'], group['doclist']['start'], docs)
    end
    GroupField.new(name, group_items['matches'], items)
  end

  def group_fields
    @group_fields ||= self['grouped'] || {}
  end

end # end groups