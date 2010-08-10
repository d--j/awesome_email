module CssParser
  class RuleSet
    def <=>(rule_set)
      if self.ids_count != rule_set.ids_count
        self.ids_count <=> rule_set.ids_count
      elsif self.class_and_pseudo_class_count != rule_set.class_and_pseudo_class_count
        self.class_and_pseudo_class_count <=> rule_set.class_and_pseudo_class_count
      else
        self.tags_count <=> rule_set.tags_count
      end
    end

    protected

    def ids_count
      @selectors.first.scan('#').size
    end

    def class_count
      @selectors.first.scan('.').size
    end

    def pseudo_class_count
      @selectors.first.scan(':').size
    end

    def class_and_pseudo_class_count
      class_count + pseudo_class_count
    end

    def tags_count
      @selectors.first.scan(/(^|\s)[a-zA-Z0-9-_]/).size
    end
  end

  class Parser
    def rules
      @rules.map{|r| r[:rules]}
    end

    def separated_rules
      self.rules.map do |rule|
        rule.selectors.map do |s|
          RuleSet.new(s, rule.declarations_to_s, rule.specificity)
        end
      end.flatten
    end
  end
end
