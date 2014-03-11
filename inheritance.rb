class Employee
  attr_accessor :name, :title, :salary, :boss

  def initialize(name, title, salary, boss)
    @name, @title, @salary, @boss = name, title, salary, boss
  end

  def bonus(multiplier)
    @salary * multiplier
  end

  def inspect
    @name
  end

end

class Manager < Employee
  attr_accessor :employee_arr

  def initialize(name, title, salary, boss, employees = [])
    super(name, title, salary, boss)
    @employee_arr = employees
  end

  def bonus(multiplier)
    multiplier *  @employee_arr.map(&:salary).inject(:+)
    #@employee_arr.inject {|tot, employee| tot+= employee.salary}
  end



end