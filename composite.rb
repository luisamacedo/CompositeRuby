# A classe Component base declara operações comuns para objetos 
# simples e complexos de uma composição.
class Component
  # @return [Component]
  def parent
    @parent
  end

  # Opcionalmente, o Componente base pode declarar uma interface para definir
  # e acessar um pai do componente em uma estrutura em árvore. Também pode fornecer 
  # alguma implementação padrão para esses métodos.
  def parent=(parent)
    @parent = parent
  end

  # Em alguns casos, seria benéfico definir as operações de gerenciamento de filhos 
  # diretamente na classe Component base. Dessa forma, você não precisará expor nenhuma 
  # classe de componente concreta ao código do cliente, mesmo durante a montagem da árvore 
  # de objetos. A desvantagem é que esses métodos estarão vazios para os componentes 
  # no nível da folha.
  def add(component)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  # @abstract
  #
  # @param [Component] component
  def remove(component)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  # Você pode fornecer um método que permita ao código do cliente
  # descobrir se um componente pode gerar filhos.
  def composite?
    false
  end

  # O componente base pode implementar algum comportamento padrão ou deixá-lo 
  # para classes concretas (declarando o método que contém 
  # o comportamento como "abstrato").
  def operation
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

# A classe Leaf representa os objetos finais de uma composição. 
# Uma folha não pode ter filhos.
#
# Geralmente, são os objetos Leaf(folha) que realizam o trabalho real, 
# enquanto os objetos Composite delegam apenas seus subcomponentes.
class Leaf < Component
  # return [String]
  def operation
    'FOLHA'
  end
end

# A classe Composite representa os componentes complexos que podem ter filhos.
# Geralmente, os objetos Composite delegam o trabalho real a seus filhos e, 
# em seguida, "resumem" o resultado.
class Composite < Component
  def initialize
    @children = []
  end

  # Um objeto composto pode adicionar ou remover outros componentes
  # (simples ou complexos) para sua propria lista de filhos.

  # @param [Component] component
  def add(component)
    @children.push(component)
    component.parent = self
  end

  # @param [Component] component
  def remove(component)
    @children.remove(component)
    component.parent = nil
  end

  # @return [Boolean]
  def composite?
    true
  end

  # O Composite executa sua lógica principal de uma maneira específica. 
  # Atravessa recursivamente todos os seus filhos, coletando e somando seus resultados.

  # Como os filhos do composto transmitem essas chamadas para seus filhos e assim 
  # por diante, toda a árvore de objetos é percorrida como resultado.
  def operation
    results = []
    @children.each { |child| results.push(child.operation) }
    "RAMO[#{results.join('+')}]"
  end
end

# O código do cliente funciona com todos os componentes através da interface base.
def client_code(component)
  puts "RESULTADO: #{component.operation}"
end

# Graças ao fato de as operações de gerenciamento filho serem declaradas na classe
# Component base, o código do cliente pode funcionar com qualquer componente,
# simples ou complexo, sem depender de suas classes concretas.
def client_code2(component1, component2)
  component1.add(component2) if component1.composite?

  print "RESULT: #{component1.operation}"
end

# Dessa forma, o código do cliente pode suportar os componentes folha simples ...
simple = Leaf.new
puts 'Cliente: Eu tenho um componente simples:'
client_code(simple)
puts "\n"

# ...as well as the complex composites.
tree = Composite.new

branch1 = Composite.new
branch1.add(Leaf.new)
branch1.add(Leaf.new)

branch2 = Composite.new
branch2.add(Leaf.new)

tree.add(branch1)
tree.add(branch2)

puts 'Cliente: Agora eu tenho uma árvore composta:'
client_code(tree)
puts "\n"

puts 'Cliente: Não preciso verificar as classes de componentes, mesmo ao gerenciar a árvore:'
client_code2(tree, simple)