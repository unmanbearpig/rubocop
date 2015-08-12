# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks whether method definitions are
      # separated by empty lines.
      class EmptyLineBetweenDefs < Cop
        MSG = 'Use empty lines between defs.'

        def on_def(node)
          nodes = [prev_node(node), node]

          return unless nodes.all?(&method(:def_node?))
          return if blank_lines_between?(*nodes)

          unless nodes.all?(&method(:single_line_def?)) &&
                 cop_config['AllowAdjacentOneLineDefs']
            add_offense(node, :keyword)
          end
        end

        private

        def def_node?(node)
          node && node.type == :def
        end

        def blank_lines_between?(first_def_node, second_def_node)
          lines_between_defs(first_def_node, second_def_node).any?(&:empty?)
        end

        def prev_node(node)
          return nil unless node.parent && node.sibling_index > 0

          node.parent.children[node.sibling_index-1]
        end

        def lines_between_defs first_def_node, second_def_node
          processed_source.lines[def_end(first_def_node)..def_start(second_def_node)-2]
        end

        def single_line_def?(node)
          def_start(node) == def_end(node)
        end

        def def_start(node)
          node.loc.keyword.line
        end

        def def_end(node)
          node.loc.end.line
        end

        def autocorrect(node)
          range = range_with_surrounding_space(node.loc.expression, :left)
          ->(corrector) { corrector.insert_before(range, "\n") }
        end
      end
    end
  end
end
