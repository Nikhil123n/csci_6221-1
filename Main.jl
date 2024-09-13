# Visitor struct to hold visitor data
struct Visitor
    name::String
    purpose::String
    check_in::String
    check_out::Union{String, Nothing}
end

# Initializing an empty list to store visitors
visitors = []

# Function to add a visitor
function add_visitor(name::String, purpose::String, check_in::String)
    visitor = Visitor(name, purpose, check_in, nothing)
    push!(visitors, visitor)
    println("Visitor added successfully!")
end

# Function to remove a visitor (by name)
function remove_visitor(name::String)
    global visitors
    visitors = filter(v -> v.name != name, visitors)
    println("Visitor removed successfully!")
end

# Function to display all visitors in a table format
function display_visitors()
    println("Visitors List:")
    println("-----------------------------------------------------")
    println("| Name          | Purpose       | Check-In   | Check-Out  |")
    println("-----------------------------------------------------")
    for v in visitors
        check_out = isnothing(v.check_out) ? "Not Checked Out" : v.check_out
        println(string("| ", lpad(v.name, 12), " | ", lpad(v.purpose, 12), " | ", lpad(v.check_in, 10), " | ", lpad(check_out, 10), " |"))
    end
    println("-----------------------------------------------------")
end

# Function to update check-out time for a visitor
function check_out_visitor(name::String, check_out::String)
    for i in 1:length(visitors)
        if visitors[i].name == name
            visitors[i] = Visitor(visitors[i].name, visitors[i].purpose, visitors[i].check_in, check_out)
            println("Check-out updated for $name!")
            return
        end
    end
    println("Visitor not found!")
end

# Main Function
function main()
    while true
        println("\nVisitor Management System")
        println("1. Add Visitor")
        println("2. Remove Visitor")
        println("3. Display Visitors")
        println("4. Check-Out Visitor")
        println("5. Exit")
        
        choice = readline()

        if choice == "1"
            println("Enter Name:")
            name = readline()
            println("Enter Purpose:")
            purpose = readline()
            println("Enter Check-In Time (e.g., 10:00 AM):")
            check_in = readline()
            add_visitor(name, purpose, check_in)

        elseif choice == "2"
            println("Enter Name of Visitor to Remove:")
            name = readline()
            remove_visitor(name)

        elseif choice == "3"
            display_visitors()

        elseif choice == "4"
            println("Enter Name of Visitor to Check-Out:")
            name = readline()
            println("Enter Check-Out Time (e.g., 05:00 PM):")
            check_out = readline()
            check_out_visitor(name, check_out)

        elseif choice == "5"
            println("Exiting...")
            break
        else
            println("Invalid choice, try again.")
        end
    end
end

# Run the main function
main()
