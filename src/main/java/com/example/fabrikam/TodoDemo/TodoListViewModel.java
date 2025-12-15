package com.example.fabrikam.TodoDemo;

import java.util.ArrayList;
import java.io.Serializable;

import javax.validation.Valid;

public class TodoListViewModel implements Serializable {

	private static final long serialVersionUID = 1L;

	@Valid
	private ArrayList<TodoItem> todoList = new ArrayList<TodoItem>();
	
	public TodoListViewModel() {}
	
	public TodoListViewModel(ArrayList<TodoItem> todoList) {
		this.todoList = todoList;
	}

	public ArrayList<TodoItem> getTodoList() {
		return todoList;
	}

	public void setTodoList(ArrayList<TodoItem> todoList) {
		this.todoList = todoList;
	}
}