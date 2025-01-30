# Create test user
user = User.create!(
  email: 'test@user.com',
  password: '123123',
  password_confirmation: '123123'
)

# Create first todo list with 2 items
todo_list_1 = user.todo_lists.create!(
  name: 'Shopping List'
)

todo_list_1.items.create!([
  {
    title: 'Grocery Shopping',
    description: 'Need to buy vegetables, fruits, and milk for the week',
    completed: false
  },
  {
    title: 'New Running Shoes',
    description: 'Look for Nike or Adidas running shoes at the mall',
    completed: false
  }
])

# Create second todo list with no items
todo_list_2 = user.todo_lists.create!(
  name: 'Work Tasks'
)

TodoList.create(name: 'Setup Rails Application')
TodoList.create(name: 'Setup Docker PG database')
TodoList.create(name: 'Create todo_lists table')
TodoList.create(name: 'Create TodoList model')
TodoList.create(name: 'Create TodoList controller')
