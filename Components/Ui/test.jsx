import React from 'react'
import styles from "./hover.module.css"

const Button = ({nameValue}) => {
  
  return (
    <div>
      <button className={styles.toolName}>
      {nameValue}
      </button>
    </div>
  )
}

export default Button