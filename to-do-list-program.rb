require 'json'

# Define a Task class
class Task 
    # Automatrically creates the getter and setter methods
    attr_accessor :id, :taskName, :description, :deadline, :status

    # Constructor methon to initialize a new Task object with attribute
    def initialize(id, taskName, description, deadline, status)
        @id = id
        @taskName = taskName
        @description = description
        @deadline = deadline
        @status = status
    end

    # Instance method to describe the Task
    def taskDetails
        "| #{formatColumn(@id.to_s)} | #{formatColumn(@taskName)} | #{formatColumn(@description)} | #{formatColumn(@deadline)} | #{formatColumn(@status)} |"
    end

    def formatColumn(value)
        value.ljust(20)
    end
end

class TaskManager
    def initialize
        @arrTask = []
        @id = 0
        loadTasksFromFile
    end

    def saveTasksToFile
        File.open('tasks.json', 'w') do |file|
            jsonData = JSON.pretty_generate(@arrTask.map { |task| { id: task.id, taskName: task.taskName, description: task.description, deadline: task.deadline, status: task.status } })
            file.write(jsonData) 
        end
    end

    def loadTasksFromFile
        if File.exist?('tasks.json')
            fileContent = File.read('tasks.json').strip # remove any leaing/trailing spaces or newlines

            if fileContent.empty?
                puts "The tasks.json file is empty."
                return
            end

            begin
                tasksData = JSON.parse(fileContent, symbolize_names: true)
                tasksData.each do |taskData|
                    task = Task.new(taskData[:id], taskData[:taskName], taskData[:description], taskData[:deadline], taskData[:status])
                    @arrTask.push(task)
                    @id = task.id if task.id > @id
                end
            rescue JSON::ParseError => e 
                puts "Error parsing JSON: #{e.message}"
            end
        else
            puts "tasks.json file does not exist."
        end
    end

    def displayAction()  
        puts "=== TO-DO List ==="
        puts "1. Create tasks"
        puts "2. List tasks"
        puts "3. Update task"
        puts "4. Delete task"
        puts "0. Exit"
    end

    def createTask
        print "Enter task's name: "
        taskName = gets.chomp
        taskName = taskName.empty? ? "No Name" : taskName
        print "Enter task's description: "
        description = gets.chomp
        description = description.empty? ? "No Description" : description
        print "Enter task's deadline: "
        deadline = gets.chomp
        deadline = deadline.empty? ? "No Deadline" : deadline
        print "Enter task's status: "
        status = gets.chomp
        status = status.empty? ? "No Status" : status
    
        if [taskName, description, deadline, status].any? {|field| field != "No Name" && field != "No Description" && field != "No Deadline" && field != "No Status"}
            @id += 1    
            myTask = Task.new(@id, taskName, description, deadline, status)
            @arrTask.push(myTask)
            saveTasksToFile
            puts "Task added with ID #{@id}."
        else
            puts "No valide information provided. Task is not created."
        end

        print "Do you want to add more task? (yes/no): "
        addMore = gets.chomp.downcase
        createTask if addMore == 'yes' || addMore == 'y'
    end

    def listTask
        if @arrTask.empty?
            puts "No tasks available."
        else
            puts "+------------------------------------------------------------------------------------------------------------------+"
            puts "| ID                   |  Task Name           | Description          | Deadline             | Status               |"
            puts "+------------------------------------------------------------------------------------------------------------------+"
            @arrTask.each do |task|
                puts task.taskDetails
            end
            puts "+------------------------------------------------------------------------------------------------------------------+"
        end
    end

    def updateTask
        listTask
        print "Enter the ID of task that you want to update: "
        id = gets.chomp.to_i
        task = @arrTask.find {|t| t.id == id}

        if task
            print "Update task's name (Current: #{task.taskName}): "
            newTaskName = gets.chomp
            task.taskName = newTaskName.empty? ? task.taskName : newTaskName
            print "Update task's description (Current: #{task.description}): "
            newDescription = gets.chomp
            task.description = newDescription.empty? ? task.description : newDescription
            print "Update task's deadline (Current: #{task.deadline}): "
            newDeadline = gets.chomp
            task.deadline = newDeadline.empty? ? task.deadline : newDeadline
            print "Update task's status (Current: #{task.status}): "
            newStatus = gets.chomp
            task.status = newStatus.empty? ? task.status : newStatus
            
            puts "Task updated."
            saveTasksToFile
        else
            puts "Task not found!"
        end

    end
    
    def deleteTask
        print "Enter the ID of task that you want to delete: "
        id = gets.chomp.to_i
        task = @arrTask.find {|t| t.id == id}

        if task 
            @arrTask.delete(task)
            saveTasksToFile
            puts "Task with #{id} deleted."
        else
            puts "Task not found!"
        end
    end

    def start
        begin
            displayAction
            print "Choose an action (1, 2, 3, 4, 0): "
            option = gets.chomp.to_i
        
            case option
            when 1
                createTask
            when 2
                listTask
            when 3
                updateTask
            when 4
                deleteTask
            when 0
                puts "Program is exiting!"
            else
                puts "Invalid option. Please choose a valid action."
            end
        end while option != 0 
    end
end
        

# Main Execution
TaskManager = TaskManager.new
TaskManager.start