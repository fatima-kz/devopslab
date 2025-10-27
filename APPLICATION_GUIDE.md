# 📱 Spring Boot Todo Application - Complete User & Developer Guide

## 🎯 **Application Overview**

The Spring Boot Todo application is a **web-based task management system** that allows users to:
- ✅ Create new todo tasks with categories
- ✅ Mark tasks as complete/incomplete  
- ✅ Update existing tasks
- ✅ View all tasks in an organized table format
- ✅ Persist data in MySQL database

### **Technology Stack**
- **Backend**: Java 8 + Spring Boot 1.5.3 + Spring Data JPA
- **Frontend**: Thymeleaf templates + Bootstrap 3.2.0 CSS
- **Database**: MySQL 5.7 with persistent storage
- **Architecture**: Model-View-Controller (MVC) pattern

---

## 🏗️ **Application Architecture Deep Dive**

### **Model Layer - Data Structure**

#### **TodoItem Entity** (`TodoItem.java`)
```java
@Entity
public class TodoItem {
    @Id
    @GeneratedValue(strategy=GenerationType.AUTO)
    private Long id;          // Unique identifier (auto-generated)
    private String category;  // Task category (e.g., "Work", "Personal")
    private String name;      // Task description
    private boolean complete; // Completion status (true/false)
}
```

**Database Schema** (Auto-created by Hibernate):
```sql
CREATE TABLE todo_item (
    id BIGINT NOT NULL AUTO_INCREMENT,
    category VARCHAR(255),
    name VARCHAR(255),
    complete BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id)
);
```

#### **TodoListViewModel** (`TodoListViewModel.java`)
```java
// Wrapper class for handling form submissions with multiple items
public class TodoListViewModel {
    private ArrayList<TodoItem> todoList;
    // Used for batch updates of todo items
}
```

### **Controller Layer - Business Logic**

#### **TodoDemoController** (`TodoDemoController.java`)

**Main Routes:**

1. **`GET /` - Display Todo List**
```java
@RequestMapping("/")
public String index(Model model) {
    // Fetch all todos from database
    ArrayList<TodoItem> todoList = repository.findAll();
    
    // Add data to view model
    model.addAttribute("newitem", new TodoItem());      // For new item form
    model.addAttribute("items", new TodoListViewModel(todoList)); // For existing items
    
    return "index"; // Render index.html template
}
```

2. **`POST /add` - Add New Todo**
```java
@RequestMapping("/add")
public String addTodo(@ModelAttribute TodoItem requestItem) {
    // Create new todo item with category and name
    TodoItem item = new TodoItem(requestItem.getCategory(), requestItem.getName());
    repository.save(item);  // Persist to database
    return "redirect:/";    // Redirect to main page
}
```

3. **`POST /update` - Update Existing Todos**
```java
@RequestMapping("/update")
public String updateTodo(@ModelAttribute TodoListViewModel requestItems) {
    // Batch update for multiple todo items (mainly for completion status)
    for (TodoItem requestItem : requestItems.getTodoList()) {
        TodoItem item = new TodoItem(requestItem.getCategory(), requestItem.getName());
        item.setComplete(requestItem.isComplete());
        item.setId(requestItem.getId());
        repository.save(item);  // Update in database
    }
    return "redirect:/";
}
```

### **View Layer - User Interface**

#### **Frontend Features** (`index.html`)

**1. Navigation Bar**
```html
<div class="navbar navbar-inverse navbar-fixed-top">
    <div class="navbar-header">
        <a class="navbar-brand" href="#">My Tasks</a>
    </div>
</div>
```

**2. Todo List Display Table**
```html
<table class="table table-bordered table-striped">
    <thead>
        <tr>
            <th>Name</th>
            <th>Category</th> 
            <th>Complete</th>
        </tr>
    </thead>
    <tbody>
        <!-- Dynamic rows for each todo item -->
        <tr th:each="item,i : *{todoList}" th:class="${item.complete}? active : warning">
            <td th:text="${item.name}">Task Name</td>
            <td th:text="${item.category}">Task Category</td>
            <td><input type="checkbox" th:field="*{todoList[__${i.index}__].complete}"/></td>
        </tr>
    </tbody>
</table>
```

**3. Add New Task Form**
```html
<form th:action="@{/add}" th:object="${newitem}" method="POST">
    <input type="text" th:field="*{name}" placeholder="Enter task name"/>
    <input type="text" th:field="*{category}" placeholder="Enter category"/>
    <button type="submit">Add Task</button>
</form>
```

---

## 🐳 **Running the Application with Docker Services**

### **Method 1: Complete Docker Compose Setup (Recommended)**

#### **Step 1: Clone and Navigate**
```bash
# Clone the repository
git clone https://github.com/fatima-kz/devopslab.git
cd mysql-spring-boot-todo

# Verify files are present
ls -la
# You should see: docker-compose.yml, Dockerfile, src/, pom.xml
```

#### **Step 2: Start All Services**
```bash
# Start application and database services
docker-compose up -d

# Check service status
docker-compose ps

# Expected output:
# NAME          COMMAND                  SERVICE   STATUS    PORTS
# mysql-todo    "docker-entrypoint.s…"   mysql     running   0.0.0.0:3306->3306/tcp
# todo-app      "java -jar app.jar"      app       running   0.0.0.0:8081->8080/tcp
```

#### **Step 3: Monitor Startup**
```bash
# Watch application logs
docker-compose logs -f app

# Watch database logs  
docker-compose logs -f mysql

# Wait for these messages:
# app: "Started TodoDemoApplication"
# mysql: "MySQL init process done. Ready for start up"
```

#### **Step 4: Access the Application**
```bash
# Open in browser
http://localhost:8081

# Health check
curl http://localhost:8081/actuator/health

# Expected health response:
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},
    "diskSpace": {"status": "UP"}
  }
}
```

### **Method 2: Step-by-Step Service Startup**

#### **Step 1: Start MySQL Database Only**
```bash
# Start only the database service
docker-compose up -d mysql

# Verify MySQL is running and healthy
docker-compose ps mysql
docker-compose logs mysql

# Test database connection
docker exec -it mysql-todo mysql -u username -pmysqlpass -e "SHOW DATABASES;"
```

#### **Step 2: Build Application Image**
```bash
# Build the Spring Boot application image
docker build -t todo-spring-boot-app .

# Verify image was created
docker images | grep todo-spring-boot-app
```

#### **Step 3: Run Application Container**
```bash
# Run application with database connection
docker run -d \
  --name todo-app \
  -p 8081:8080 \
  --network mysql-spring-boot-todo_todo-network \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://mysql-todo:3306/tododb \
  -e SPRING_DATASOURCE_USERNAME=username \
  -e SPRING_DATASOURCE_PASSWORD=mysqlpass \
  todo-spring-boot-app

# Check application logs
docker logs -f todo-app
```

### **Method 3: Pull from Docker Hub**

#### **Use Pre-built Image**
```bash
# Pull the latest image from Docker Hub
docker pull fatimakz/todo-spring-boot-app:latest

# Start database first
docker-compose up -d mysql

# Run application using pre-built image
docker run -d \
  --name todo-app-hub \
  -p 8082:8080 \
  --network mysql-spring-boot-todo_todo-network \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://mysql-todo:3306/tododb \
  -e SPRING_DATASOURCE_USERNAME=username \
  -e SPRING_DATASOURCE_PASSWORD=mysqlpass \
  fatimakz/todo-spring-boot-app:latest

# Access at: http://localhost:8082
```

---

## 📱 **Using the Todo Application**

### **Main Interface Features**

#### **1. View All Tasks**
- **URL**: `http://localhost:8081`
- **Description**: Displays all todo items in a table format
- **Visual Indicators**:
  - 🟨 **Yellow rows** (warning): Incomplete tasks
  - 🟩 **Green rows** (active): Completed tasks

#### **2. Add New Task**
**Location**: Bottom form on main page

**Steps**:
1. Enter **Task Name** (e.g., "Complete DevOps project")
2. Enter **Task Category** (e.g., "School", "Work", "Personal")
3. Click **"Add Task"** button
4. Page refreshes with new task in the table

**Example**:
```
Task Name: "Study for DevOps exam"
Category: "Education"
Result: New row appears in yellow (incomplete)
```

#### **3. Update Task Completion Status**
**Location**: Checkboxes in the "Complete" column

**Steps**:
1. Check/uncheck boxes next to tasks
2. Click **"Update Tasks"** button
3. Page refreshes with updated row colors

**Visual Feedback**:
- ✅ **Checked** = Green row (completed)
- ☐ **Unchecked** = Yellow row (pending)

### **Application Workflow Example**

#### **Scenario: Managing Daily Tasks**

**Step 1: Add Tasks**
```
1. Task: "Review Docker documentation"    Category: "Learning"
2. Task: "Complete CI/CD pipeline"        Category: "Project"  
3. Task: "Prepare viva presentation"      Category: "Academic"
```

**Step 2: Work on Tasks**
- All tasks initially show as yellow (incomplete)
- Complete "Review Docker documentation"
- Check the box next to that task
- Click "Update Tasks"

**Step 3: Final Status**
```
✅ Review Docker documentation [GREEN ROW]
☐ Complete CI/CD pipeline     [YELLOW ROW] 
☐ Prepare viva presentation   [YELLOW ROW]
```

---

## 🔍 **Database Operations and Verification**

### **Direct Database Access**

#### **Connect to MySQL Container**
```bash
# Access MySQL shell
docker exec -it mysql-todo mysql -u username -pmysqlpass tododb

# Or using root access
docker exec -it mysql-todo mysql -u root -pmysqlpass tododb
```

#### **View Database Schema**
```sql
-- Show all tables
SHOW TABLES;

-- Describe todo_item table structure
DESCRIBE todo_item;

-- Expected output:
+----------+--------------+------+-----+---------+----------------+
| Field    | Type         | Null | Key | Default | Extra          |
+----------+--------------+------+-----+---------+----------------+
| id       | bigint(20)   | NO   | PRI | NULL    | auto_increment |
| category | varchar(255) | YES  |     | NULL    |                |
| complete | bit(1)       | YES  |     | NULL    |                |
| name     | varchar(255) | YES  |     | NULL    |                |
+----------+--------------+------+-----+---------+----------------+
```

#### **Query Todo Data**
```sql
-- View all todo items
SELECT * FROM todo_item;

-- View only incomplete tasks
SELECT * FROM todo_item WHERE complete = 0;

-- View tasks by category
SELECT * FROM todo_item WHERE category = 'Work';

-- Count tasks by status
SELECT 
    complete,
    COUNT(*) as count,
    CASE complete WHEN 1 THEN 'Completed' ELSE 'Pending' END as status
FROM todo_item 
GROUP BY complete;
```

### **Sample Database Content**
```sql
-- After adding and updating some tasks
SELECT id, name, category, complete FROM todo_item;

+----+-------------------------+-----------+----------+
| id | name                    | category  | complete |
+----+-------------------------+-----------+----------+
|  1 | Review Docker docs      | Learning  |        1 |
|  2 | Complete CI/CD pipeline | Project   |        0 |
|  3 | Prepare viva           | Academic  |        0 |
|  4 | Update documentation   | Work      |        1 |
+----+-------------------------+-----------+----------+
```

---

## 🛠️ **Troubleshooting Common Issues**

### **Issue 1: Application Won't Start**

**Symptoms**: Container starts but health check fails
```bash
# Check application logs
docker-compose logs app

# Common error messages and solutions:
```

**Error**: `Connection refused to MySQL`
```bash
# Solution: Ensure MySQL is ready first
docker-compose up -d mysql
docker-compose logs mysql  # Wait for "ready for connections"
docker-compose up -d app
```

**Error**: `Table 'tododb.todo_item' doesn't exist`
```bash
# Solution: Check database permissions and auto-creation
docker exec -it mysql-todo mysql -u username -pmysqlpass -e "USE tododb; SHOW TABLES;"
```

### **Issue 2: Database Connection Problems**

**Check Network Connectivity**:
```bash
# Verify containers can communicate
docker network ls
docker network inspect mysql-spring-boot-todo_todo-network

# Test connectivity from app container
docker exec -it todo-app ping mysql-todo
```

**Verify Database Credentials**:
```bash
# Check environment variables in app container
docker exec -it todo-app env | grep SPRING_DATASOURCE

# Expected output:
SPRING_DATASOURCE_URL=jdbc:mysql://mysql-todo:3306/tododb
SPRING_DATASOURCE_USERNAME=username
SPRING_DATASOURCE_PASSWORD=mysqlpass
```

### **Issue 3: Port Conflicts**

**Error**: `Port 8081 already in use`
```bash
# Check what's using the port
netstat -tlnp | grep 8081
# or on Windows:
netstat -an | findstr 8081

# Solution: Use different port
docker-compose down
# Edit docker-compose.yml: change "8081:8080" to "8082:8080"
docker-compose up -d
```

---

## 🔧 **Development and Customization**

### **Modifying the Application**

#### **Add New Fields to Todo Items**
1. **Update Entity** (`TodoItem.java`):
```java
@Entity
public class TodoItem {
    // Existing fields...
    private Date dueDate;
    private String priority;
    
    // Add getters and setters
}
```

2. **Update Template** (`index.html`):
```html
<th>Due Date</th>
<th>Priority</th>
<!-- Add corresponding <td> elements -->
```

3. **Rebuild and Test**:
```bash
docker-compose down
docker-compose build app
docker-compose up -d
```

### **Environment Configuration**

#### **Development Mode**
```bash
# Create docker-compose.override.yml for development
version: '3.8'
services:
  app:
    environment:
      - SPRING_JPA_SHOW_SQL=true
      - LOGGING_LEVEL_ROOT=DEBUG
    volumes:
      - ./src:/app/src  # Hot reload for development
```

#### **Production Mode**
```bash
# Use production configuration
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## 📊 **Monitoring and Health Checks**

### **Application Health Endpoints**

#### **Health Check**
```bash
# Basic health check
curl http://localhost:8081/actuator/health

# Detailed health info
curl http://localhost:8081/actuator/health | jq

# Expected healthy response:
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "MySQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP"
    }
  }
}
```

#### **Application Info**
```bash
# Application information
curl http://localhost:8081/actuator/info

# Response includes build info, git commit, etc.
```

### **Container Health Monitoring**

#### **Docker Health Status**
```bash
# Check container health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Expected output:
NAMES       STATUS                    PORTS
todo-app    Up 5 minutes (healthy)    0.0.0.0:8081->8080/tcp
mysql-todo  Up 5 minutes (healthy)    0.0.0.0:3306->3306/tcp
```

#### **Resource Usage**
```bash
# Monitor resource consumption
docker stats todo-app mysql-todo

# Output shows CPU, memory, network I/O in real-time
```

---

## 🎯 **Application Features Summary**

### **User Features**
✅ **Create Tasks**: Add new todo items with name and category  
✅ **Update Status**: Mark tasks as complete/incomplete  
✅ **Visual Feedback**: Color-coded rows for task status  
✅ **Persistent Storage**: Data survives container restarts  
✅ **Responsive UI**: Bootstrap-based mobile-friendly interface  

### **Technical Features**
✅ **Spring Boot Framework**: Enterprise-grade Java application  
✅ **JPA/Hibernate ORM**: Automatic database schema management  
✅ **Thymeleaf Templates**: Server-side rendering with dynamic content  
✅ **MySQL Integration**: Relational database with ACID properties  
✅ **Health Monitoring**: Built-in health check endpoints  
✅ **Docker Ready**: Fully containerized application stack  

### **DevOps Features**  
✅ **Environment Variables**: Configurable database connections  
✅ **Health Checks**: Container and application level monitoring  
✅ **Logging**: Structured application and access logs  
✅ **Multi-Stage Builds**: Optimized Docker images  
✅ **Service Discovery**: Container-to-container communication  

---

## 🚀 **Next Steps for Enhancement**

### **Possible Improvements**
1. **Add REST API endpoints** for mobile app integration
2. **Implement user authentication** for multi-user support  
3. **Add due dates and priorities** for better task management
4. **Include file attachments** for task documentation
5. **Add search and filtering** capabilities
6. **Implement task categories management** 

### **Advanced DevOps Features**
1. **Add Redis caching** for improved performance
2. **Implement load balancing** for high availability
3. **Add metrics collection** with Prometheus/Grafana
4. **Set up log aggregation** with ELK stack
5. **Implement blue-green deployments**

---

## 💡 **Key Learning Points**

### **Spring Boot Concepts Demonstrated**
- MVC architecture pattern
- Dependency injection with @Autowired  
- Entity mapping with JPA annotations
- Thymeleaf template integration
- Configuration with application.properties

### **Docker Concepts Demonstrated**  
- Multi-stage builds for optimization
- Service orchestration with Docker Compose
- Environment variable configuration
- Health checks and monitoring
- Volume mounting for data persistence

### **DevOps Concepts Demonstrated**
- Containerization best practices
- Service dependency management  
- Configuration management
- Health monitoring and observability
- Infrastructure as Code principles

**This application serves as an excellent foundation for understanding modern web application development with Spring Boot and professional DevOps practices!** 🎉